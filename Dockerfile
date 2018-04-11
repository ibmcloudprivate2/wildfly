FROM jboss/wildfly
ADD helloworld.war /opt/jboss/wildfly/standalone/deployments/
