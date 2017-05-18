FROM alpine:3.5
LABEL maintainer "pete@digitalidentitylabs.com"

RUN  apk add --update --no-cache openldap
COPY source/openldap /etc/openldap


USER root
EXPOSE 389

ENTRYPOINT exec /etc/openldap/startup.sh
