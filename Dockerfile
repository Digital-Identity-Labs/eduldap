FROM alpine:3.9

LABEL description="Configurable OpenLDAP service with education schema" \
      version="0.3.0" \
      maintainer="pete@digitalidentitylabs.com"

RUN  apk add --update --no-cache \
     openldap \
     openldap-backend-all \
     openldap-clients \
     openldap-mqtt \
     openldap-overlay-all \
     openldap-passwd-pbkdf2

COPY etcfs /etc


USER root
EXPOSE 389

ENTRYPOINT exec /etc/openldap/startup.sh