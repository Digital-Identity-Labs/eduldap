FROM alpine:3.14

LABEL description="Configurable OpenLDAP service with education schema and demo data" \
      version="1.0.0" \
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
COPY optfs /opt

ENV EDULDAP_ENV=development \
    ADMIN_SECRET="" \
    DEBUG_LEVEL=256 \
    BASE_DN='dc=demo,dc=university' \
    DATABASE=default \
    SCHEMA="core cosine nis misc pmi ppolicy dyngroup inetorgperson eduperson schac ssh" \
    SEED=default \
    RESET=false \
    TIDY=true \
    EDULDAP_HOME=/opt/eduldap \
    OPENLDAP_ETC=/etc/openldap \
    DATA_DIR=/var/lib/openldap/openldap-data \
    RUN_DIR=/var/run/openldap \
    SOCK_DIR=/var/lib/openldap/run \
    AUTO_INIT=true \
    SLAPD_URLS="ldap:/// ldapi:///" \
    SLAPD_OPTIONS="  "

ENV CONFIG_DIR=${OPENLDAP_ETC}/slapd.d \
    DATABASE_FILE=${EDULDAP_HOME}/bootstrap/databases/${DATABASE}.ldif \
    SEED_FILE=${EDULDAP_HOME}/bootstrap/seeds/${SEED}.ldif \
    PATH=${PATH}:/opt/eduldap/bin

USER root
EXPOSE 389 636

#ENTRYPOINT /etc/eduldap/bin/eduldap.sh
ENTRYPOINT ["sh"]
CMD []

HEALTHCHECK --interval=10s --timeout=2s --start-period=5s --retries=2  CMD ldapwhoami -Y EXTERNAL -H ldapi:/// || exit 1
