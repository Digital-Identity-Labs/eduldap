FROM alpine:3.5
MAINTAINER Pete Birkinshaw <pete@digitalidentitylabs.com>

RUN  apk add --update --no-cache openldap
COPY source/openldap /etc/openldap


USER root
EXPOSE 389

CMD ["slapd", "-d", "389", "-u", "ldap", "-g", "ldap"]

