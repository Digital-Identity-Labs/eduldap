#!/bin/sh

## These variables are for private use, unlikely to change
CONFIG_DIR=/var/lib/openldap/slapd.d
DATA_DIR=/var/lib/openldap/openldap-data
ETC=/etc/openldap

## These variables can be passed on commandline, Dockerfile, etc to change behaviour
ENV_MODE=${ENV_MODE:-development}
ADMIN_SECRET=${ADMIN_SECRET:-`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1`}
BASE_DN=${BASE_DN:-'dc=demo,dc=university'}
DEBUG_LEVEL=${DEBUG_LEVEL:-0}
DATABASE=${DATABASE:-default}
SEED=${SEED:-default}

## Configuration data will be stored here
mkdir -p $CONFIG_DIR
chown -R ldap:ldap $CONFIG_DIR

if [ ! -f "$CONFIG_DIR/cn=config.ldif" ]; then

  echo "No LDAP configuration has been found. Initialising new configuration!"

  echo ":: Mode: ${ENV_MODE}"

  echo ":: Rewriting admin password in '${DATABASE}' database"
  sed -i "s/XSECRET/${ADMIN_SECRET}/g" $ETC/databases/$DATABASE.ldif

  if [ $ENV_MODE == "production" ]; then
    echo "    Admin password: \$ADMIN_SECRET"
  else
    echo "    Admin password: ${ADMIN_SECRET}"
  fi

  echo ":: Setting up core LDAP server configuration"
  slapadd -n0 -F $CONFIG_DIR -l $ETC/slapd.ldif

  echo ":: Importing schema:"
  for file in $ETC/schema/*.ldif
  do
    echo "    $file"
    slapadd -n0 -F $CONFIG_DIR -l $file
  done

  slapadd -n0 -F $CONFIG_DIR -l $ETC/modules.ldif

  echo ":: Available databases:"
  for file in $ETC/databases/*.ldif
  do
    echo "    $file"
  done

  echo ":: Adding database definition, ACLs, etc from $DATABASE.ldif"
  slapadd -n0 -F $CONFIG_DIR -l $ETC/databases/$DATABASE.ldif

  echo ":: Testing configuration..."
  #/usr/sbin/slapd  -T t  -u ldap -F $CONFIG_DIR

  echo ":: Available seed data:"
  for file in $ETC/seeds/*.ldif
  do
    echo "    $file"
  done

  echo ":: Loading seed data from $SEED.ldif"
  slapadd -n1 -F $CONFIG_DIR -l $ETC/seeds/$SEED.ldif

  echo ":: Post configuration adjustments"
  slapadd -n0 -F $CONFIG_DIR -l $ETC/extras.ldif

  chown -R ldap:ldap $CONFIG_DIR
  chown -R ldap:ldap $DATA_DIR/*
fi

echo "Starting LDAP service..."
exec /usr/sbin/slapd -F $CONFIG_DIR -d $DEBUG_LEVEL -u ldap -g ldap


