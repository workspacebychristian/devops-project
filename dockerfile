#copy tomcat image
FROM tomcat:latest
#copy artifact on user home to container
COPY ./webapp.war /usr/local/tomcat/webapps
#copy content of webapps.dist to webapps (both within the same container)
RUN cp -r /usr/local/tomcat/webapps.dist/* /usr/local/tomcat/webapps
