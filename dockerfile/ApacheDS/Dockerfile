FROM docker-apacheds:1.0
ENV DS_HOME /opt/apacheds-2.0.0.AM26/bin
WORKDIR ${DS_HOME}
EXPOSE 10389 10636 60088 60464 8080 8443
ENTRYPOINT ./apacheds console default