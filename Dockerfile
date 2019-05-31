<<<<<<< Updated upstream
FROM alpine:3.9

LABEL description="Configurable OpenLDAP service with education schema" \
      version="0.4.0" \
      maintainer="pete@digitalidentitylabs.com"

RUN  apk add --update --no-cache \
     openldap \
     openldap-backend-all \
     openldap-clients \
     openldap-mqtt \
     openldap-overlay-all \
     openldap-passwd-pbkdf2 \
     gettext

ENV ENV="/etc/profile.d/eduldap.sh"

COPY etcfs /etc

RUN chmod a+x /etc/profile.d/eduldap.sh

USER root
EXPOSE 389 636

#ENTRYPOINT /etc/eduldap/bin/eduldap.sh
ENTRYPOINT ["/etc/eduldap/bin/eduldap"]
CMD []


HEALTHCHECK --interval=10s --timeout=2s --start-period=5s --retries=2  CMD ldapwhoami -Y EXTERNAL -H ldapi:/// || exit 1
