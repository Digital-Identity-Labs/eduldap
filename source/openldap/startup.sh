#!/bin/sh

set -e
set -u
#set -x

## Convert full DN to an LDIF line for the naming attribute (used for root entry)
function dn_to_na {
  echo $1 | cut -d',' -f 1 | sed 's/=/: /'
}

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
RESET=${RESET:-false}

## Derived from user options
DATABASE_FILE=$ETC/databases/$DATABASE.ldif
SEED_FILE=$ETC/seeds/$SEED.ldif
DATABASE_SUFFIX=`grep olcSuffix $DATABASE_FILE | head -1 | cut -d':' -f 2 | sed 's/^ //'`
ONA=$(dn_to_na $DATABASE_SUFFIX)
NNA=$(dn_to_na $BASE_DN)

## Configuration data will be stored here
mkdir -p $CONFIG_DIR
chown -R ldap:ldap $CONFIG_DIR

## Make sure we have files for pids
mkdir -p /var/run/openldap
chown -R ldap:ldap /var/run/openldap

echo ":: Mode: ${ENV_MODE}"

if [ "$RESET" = "true" ]; then
  echo "Resetting data and configuration as RESET=true..."
  rm -rfv $CONFIG_DIR/*
  rm -rfv $DATA_DIR/*.mdb
  echo "Reset complete"
fi

## If this is the first run (after image creation) we need to set up the LDAP server config and data
if [ ! -f "$CONFIG_DIR/cn=config.ldif" ]; then

  echo "No LDAP configuration has been found. Initialising new configuration!"

  echo ":: Rewriting admin password in '${DATABASE}' database"
  sed -i "s/XSECRET/${ADMIN_SECRET}/g" $DATABASE_FILE

  if [ $ENV_MODE == "production" ]; then
    echo "    Admin password: \$ADMIN_SECRET"
  else
    echo "    Admin password: ${ADMIN_SECRET}"
  fi

  if [ $BASE_DN != $DATABASE_SUFFIX ]; then
    echo ":: Rewriting Suffix in Database configuration from $DATABASE_SUFFIX to $BASE_DN..."
    sed -i "s/${DATABASE_SUFFIX}/${BASE_DN}/g" $DATABASE_FILE
    echo ":: Rewriting Suffix in Seed configuration from $DATABASE_SUFFIX to $BASE_DN..."
    sed -i "s/${DATABASE_SUFFIX}/${BASE_DN}/g" $SEED_FILE
    sed -i "s/^${ONA}$/${NNA}/g"               $SEED_FILE
  fi

  echo ":: Setting up core LDAP server configuration"
  slapadd -d0 -n0 -F $CONFIG_DIR -l $ETC/slapd.ldif

  echo ":: Importing schema:"
  for file in $ETC/schema/*.ldif
  do
    echo "    $file"
    slapadd  -d0 -n0 -F $CONFIG_DIR -l $file
  done

  slapadd -d0 -n0 -F $CONFIG_DIR -l $ETC/modules.ldif

  echo ":: Available databases:"
  for file in $ETC/databases/*.ldif
  do
    echo "    $file"
  done

  echo ":: Adding database definition, ACLs, etc from $DATABASE.ldif"
  slapadd  -d0 -n0 -F $CONFIG_DIR -l $DATABASE_FILE

  echo ":: Available seed data:"
  for file in $ETC/seeds/*.ldif
  do
    echo "    $file"
  done

  echo ":: Loading seed data from $SEED.ldif"
  slapadd  -d0 -n1 -F $CONFIG_DIR -l $SEED_FILE

  echo ":: Post configuration adjustments"
  slapadd  -d0 -n0 -F $CONFIG_DIR -l $ETC/extras.ldif

  chown -R ldap:ldap $CONFIG_DIR
  chown -R ldap:ldap $DATA_DIR/*

  echo ":: Testing configuration..."
  /usr/sbin/slaptest -F $CONFIG_DIR

fi

echo "Starting LDAP service..."
exec /usr/sbin/slapd -F $CONFIG_DIR -d $DEBUG_LEVEL -u ldap -g ldap


