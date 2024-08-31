#copy tomcat image
FROM tomcat:latest
#copy artifact on user home to container
COPY target/my-maven-project-1.0-SNAPSHOT.jar /usr/local/tomcat/webapps
#copy content of webapps.dist to webapps (both within the same container)
RUN cp -r /usr/local/tomcat/webapps.dist/* /usr/local/tomcat/webapps
