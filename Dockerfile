# Dockerfile for jenkins/sfyt integration demonstration
# we will use syft to look for curl in the image 
# and kill the jenkins job if we find it
FROM alpine:latest
RUN apk add curl
CMD /bin/sh
