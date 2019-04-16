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
     openldap-passwd-pbkdf2 \
     gettext

COPY etcfs /etc


USER root
EXPOSE 389 636

ENTRYPOINT /etc/eduldap/bin/startup.sh

HEALTHCHECK --interval=10s --timeout=2s --start-period=5s --retries=2  CMD ldapwhoami -Y EXTERNAL -H ldapi:/// || exit 1
