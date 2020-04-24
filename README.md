![Atlassian Jira Software](https://wac-cdn.atlassian.com/dam/jcr:826c97dc-1f5c-4955-bfcc-ea17d6b0c095/jira%20software-icon-gradient-blue.svg?cdnVersion=492)

Jira Software is a software development tool used by agile teams.

* Learn more about Jira Software: [https://www.atlassian.com/software/jira](https://www.atlassian.com/software/jira)

This Docker container makes it easy to get an instance of Jira Software.

# Quick Start

For the `JIRA_HOME` directory that is used to store application data (amongst
other things) we recommend mounting a host directory as a [data
volume](https://docs.docker.com/engine/tutorials/dockervolumes/#/data-volumes),
or via a named volume if using a docker version >= 1.9.

To get started you can use a data volume, or named volumes. In this example
we'll use named volumes.

    docker volume create --name jiraVolume
    docker run -v jiraVolume:/var/atlassian/application-data/jira --name="jira" -d -p 8080:8080 geeoz/atlassian-jira-software


**Success**. Jira is now available on [http://localhost:8080](http://localhost:8080)*

Please ensure your container has the necessary resources allocated to it. We
recommend 2GiB of memory allocated to accommodate the application server. See
[System Requirements](https://confluence.atlassian.com/adminjiraserver071/jira-applications-installation-requirements-802592164.html)
for further information.


_* Note: If you are using `docker-machine` on Mac OS X, please use `open
http://$(docker-machine ip default):8080` instead._

# Configuring Jira Software

This Docker image is intended to be configured from its environment; the
provided information is used to generate the application configuration files
from templates. Most aspects of the deployment can be configured in this manner; 
the necessary environment variables are documented below.

You can configure a small set of things by supplying the following environment variables

| Environment Variable              | Description |
| --------------------------------- | ----------- |
| CATALINA_CONNECTOR_PROXYNAME      | The reverse proxy's fully qualified hostname. |
| CATALINA_CONNECTOR_PROXYPORT      | The reverse proxy's port number via which Jira is accessed. |
| CATALINA_CONNECTOR_SCHEME         | The protocol via which Jira is accessed. |
| CATALINA_CONNECTOR_SECURE         | Set 'true' if CATALINA_CONNECTOR_SCHEME is 'https'. |
| CATALINA_CONTEXT_PATH             | The context path the application is served over. |
| JAVA_OPTS                         | The standard environment variable that some servers and other java apps append to the call that executes the java command. |
| CROWD_ENABLE                      | Enable Crowd Integration and SSO |
| APPLICATION_NAME                  | The name that the application will use when authenticating with the Crowd server. |
| APPLICATION_PASSWORD              | The password that the application will use when authenticating with the Crowd server. |
| APPLICATION_LOGIN_URL             | Crowd will redirect the user to this URL if their authentication token expires or is invalid due to security restrictions. |
| CROWD_SERVER_URL                  | The URL to use when connecting with the integration libraries to communicate with the Crowd server. |
| CROWD_BASE_URL                    | The URL used by Crowd to create the full URL to be sent to users that reset their passwords. |
| SESSION_ISAUTHENTICATED           | The session key to use when storing a Boolean value indicating whether the user is authenticated or not. |
| SESSION_TOKENKEY                  | The session key to use when storing a String value of the user's authentication token. |
| SESSION_VALIDATIONINTERVAL        | The number of minutes to cache authentication validation in the session. If this value is set to 0, each HTTP request will be authenticated with the Crowd server. |
| SESSION_LASTVALIDATION            | The session key to use when storing a Date value of the user's last authentication. |
You can read more about optional settings in the [crowd.properties](https://confluence.atlassian.com/crowd/the-crowd-properties-file-98665664.html) file.
