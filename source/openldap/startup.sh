#!/usr/bin/sh

CONFIG_DIR=/var/lib/openldap/slapd.d
ETC=/etc/openldap
PASSWORD=$1

## Configuration data will be stored here
mkdir -p $CONFIG_DIR
chown -R ldap:ldap $CONFIG_DIR

if [ ! -f "$CONFIG_DIR/cn=config.ldif" ]; then
  echo "Setting up initial LDAP server configuration..."
  slapadd -n0 -F $CONFIG_DIR -l $ETC/slapd.ldif

  for file in $ETC/schema/*.ldif
  do
    echo "Importing schema: $file..."
    slapadd -n0 -F $CONFIG_DIR -l $file
  done

  slapadd -n0 -F $CONFIG_DIR -l $ETC/modules.ldif
  slapadd -n0 -F $CONFIG_DIR -l $ETC/access.ldif

  echo "Available databases:"
  for file in $ETC/databases/*.ldif
  do
    echo " $file"
  done



  slapadd -n0 -F $CONFIG_DIR -l $ETC/extras.ldif



fi



