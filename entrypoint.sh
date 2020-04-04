#!/bin/bash
set -euo pipefail

# Setup Catalina Opts
: ${CATALINA_CONNECTOR_PROXYNAME:=}
: ${CATALINA_CONNECTOR_PROXYPORT:=}
: ${CATALINA_CONNECTOR_SCHEME:=http}
: ${CATALINA_CONNECTOR_SECURE:=false}
: ${CATALINA_CONTEXT_PATH:=}

: ${CATALINA_OPTS:=}

: ${JAVA_OPTS:=}

CATALINA_OPTS="${CATALINA_OPTS} -DcatalinaConnectorProxyName=${CATALINA_CONNECTOR_PROXYNAME}"
CATALINA_OPTS="${CATALINA_OPTS} -DcatalinaConnectorProxyPort=${CATALINA_CONNECTOR_PROXYPORT}"
CATALINA_OPTS="${CATALINA_OPTS} -DcatalinaConnectorScheme=${CATALINA_CONNECTOR_SCHEME}"
CATALINA_OPTS="${CATALINA_OPTS} -DcatalinaConnectorSecure=${CATALINA_CONNECTOR_SECURE}"
CATALINA_OPTS="${CATALINA_OPTS} -DcatalinaContextPath=${CATALINA_CONTEXT_PATH}"

export JAVA_OPTS="${JAVA_OPTS} ${CATALINA_OPTS}"

: ${CROWD_ENABLE:=false}
: ${CROWD_PROPERTIES_PATH:=${JIRA_INSTALL_DIR}/atlassian-jira/WEB-INF/classes/crowd.properties}
: ${APPLICATION_NAME:=}}
: ${APPLICATION_PASSWORD:=}}
: ${APPLICATION_LOGIN_URL:=}}
: ${CROWD_SERVER_URL:=}}
: ${CROWD_BASE_URL:=}}
: ${SESSION_ISAUTHENTICATED:=session.isauthenticated}}
: ${SESSION_TOKENKEY:=session.tokenkey}}
: ${SESSION_VALIDATIONINTERVAL:=2}}
: ${SESSION_LASTVALIDATION:=session.lastvalidation}}

# Cleanly set/unset values in crowd.properties
function set_crowd_property {
    if [ -z $2 ]; then
        if [ -f "${CROWD_PROPERTIES_PATH}" ]; then
            sed -i -e "/^${1}/d" "${CROWD_PROPERTIES_PATH}"
        fi
        return
    fi
    if [ ! -f "${CROWD_PROPERTIES_PATH}" ]; then
        echo "${1}=${2}" >> "${CROWD_PROPERTIES_PATH}"
    elif grep "^${1}" "${CROWD_PROPERTIES_PATH}"; then
        sed -i -e "s#^${1}=.*#${1}=${2}#g" "${CROWD_PROPERTIES_PATH}"
    else
        echo "${1}=${2}" >> "${CROWD_PROPERTIES_PATH}"
    fi
}

if [ "${CROWD_ENABLE}" == "true" ]; then
    sed -i -e 's/"com.atlassian.jira.security.login.JiraSeraphAuthenticator"/"com.atlassian.jira.security.login.SSOSeraphAuthenticator"/' ${JIRA_INSTALL_DIR}/atlassian-jira/WEB-INF/classes/seraph-config.xml

    set_crowd_property "application.name" "${APPLICATION_NAME}"
    set_crowd_property "application.password" "${APPLICATION_PASSWORD}"
    set_crowd_property "application.login.url" "${APPLICATION_LOGIN_URL}"
    set_crowd_property "crowd.server.url" "${CROWD_SERVER_URL}"
    set_crowd_property "crowd.base.url" "${CROWD_BASE_URL}"
    set_crowd_property "session.isauthenticated" "${SESSION_ISAUTHENTICATED}"
    set_crowd_property "session.tokenkey" "${SESSION_TOKENKEY}"
    set_crowd_property "session.validationinterval" "${SESSION_VALIDATIONINTERVAL}"
    set_crowd_property "session.lastvalidation" "${SESSION_LASTVALIDATION}"

    chmod -R 700 "${JIRA_INSTALL_DIR}" && chown -R "${RUN_USER}:${RUN_GROUP}" "${JIRA_INSTALL_DIR}"
fi

# Start Jira as the correct user
if [ "${UID}" -eq 0 ]; then
    echo "User is currently root. Will change directory ownership to ${RUN_USER}:${RUN_GROUP}, then downgrade permission to ${RUN_USER}"
    PERMISSIONS_SIGNATURE=$(stat -c "%u:%U:%a" "${JIRA_HOME}")
    EXPECTED_PERMISSIONS=$(id -u ${RUN_USER}):${RUN_USER}:700
    if [ "${PERMISSIONS_SIGNATURE}" != "${EXPECTED_PERMISSIONS}" ]; then
        chmod -R 700 "${JIRA_HOME}" &&
            chown -R "${RUN_USER}:${RUN_GROUP}" "${JIRA_HOME}"
    fi
    # Now drop privileges
    exec su -s /bin/bash "${RUN_USER}" -c "$JIRA_INSTALL_DIR/bin/start-jira.sh $@"
else
    exec "$JIRA_INSTALL_DIR/bin/start-jira.sh" "$@"
fi
