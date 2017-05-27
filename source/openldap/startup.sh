#!/bin/sh

CONFIG_DIR=/var/lib/openldap/slapd.d
DATA_DIR=/var/lib/openldap/openldap-data
ETC=/etc/openldap

PASSWORD=$1
DEBUG_LEVEL=0
DATABASE=default
SEED=default

## Configuration data will be stored here
mkdir -p $CONFIG_DIR
chown -R ldap:ldap $CONFIG_DIR

if [ ! -f "$CONFIG_DIR/cn=config.ldif" ]; then
  echo "No LDAP configuration has been found. Initialising new configuration!"
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


