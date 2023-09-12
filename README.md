# EduLDAP

A simple OpenLDAP service for education use, designed to be quick to use during development and as a base for production services. 

EduLDAP wraps up the OpenLDAP software in a script that makes it quick and easy to start up a ready-to-use LDAP service. It also contains optional database schema that are widely used in higher education.

## Advantages

* Small size and few layers
* Alpine's security architecture
* Low memory usage (a simple service will use about 10MB RAM)
* Bootstraps its configuration and directory contents
* Uses LDIF configuration backend, so config can replicate
* Education schemas as used by SAML/Shibboleth IdPs: eduPerson, SCHAC
* Includes variety of ready-made directories for quick testing
* Easy customisation using environment variables
* Production and development modes
* Logging to stdout, healthcheck, zombie-proof process management and other Docker best-practices
* Even a few tests

## Quickstart

With no configuration EduLDAP starts a LDAP service suitable for development purposes. The admin password is randomly generated and printed to STDOUT:

```
$ docker run --rm --name ldap -ti eduldap

[INFO  tini (1)] Spawned child process 'eduldap' with pid '7'
:: Environment: development
No LDAP configuration has been found. Initialising new configuration!                                                                                                                            
:: Rewriting admin password in 'default' database
    Admin password: tvT1sr2hisaLZe4REhVUXMtQbfNr5SJS                                                                                                                                             
:: Setting up core LDAP server configuration                                                                                                                                                     
:: Importing schema:                                                                            
    /opt/eduldap/bootstrap/schema/core.ldif                                                     
    /opt/eduldap/bootstrap/schema/cosine.ldif
    /opt/eduldap/bootstrap/schema/nis.ldif     
    /opt/eduldap/bootstrap/schema/misc.ldif
    /opt/eduldap/bootstrap/schema/pmi.ldif
    /opt/eduldap/bootstrap/schema/ppolicy.ldif                                                                                                                                                   
    /opt/eduldap/bootstrap/schema/dyngroup.ldif
    /opt/eduldap/bootstrap/schema/inetorgperson.ldif                                                                                                                                             
    /opt/eduldap/bootstrap/schema/eduperson.ldif                                                                                                                                                 
    /opt/eduldap/bootstrap/schema/schac.ldif                                                    
    /opt/eduldap/bootstrap/schema/ssh.ldif                                                      
:: Available databases:       
    /opt/eduldap/bootstrap/databases/default.ldif
    /opt/eduldap/bootstrap/databases/none.ldif
:: Adding database definition, ACLs, etc from default.ldif
:: Available seed data:                                                                         
    /opt/eduldap/bootstrap/seeds/bigcom.ldif                                                    
    /opt/eduldap/bootstrap/seeds/default.ldif
    /opt/eduldap/bootstrap/seeds/none.ldif                                                      
:: Loading seed data from default.ldif
:: Post configuration adjustments
:: Removing unused files from /etc/openldap as TIDY=true...
:: Testing configuration...
config file testing succeeded
Starting LDAP service
64d22cb3 @(#) $OpenLDAP: slapd  (May 17 2021 12:16:56) $
        openldap
64d22cb3 slapd starting
```

As well as setting a admin password it loads a list of LDAP schemas including inetorgperson and eduperson.

## Configuration

Most of EduLDAP can be configured using environment variables:

| Name | Default | Notes |
|------|---------|-------|
| ADMIN_SECRET | ""  | Used for setting admin password | 
| ADMIN_SECRET_FILE | | Used for setting admin password via file |
| AUTO_INIT | true  | | 
| BASE_DN | 'dc=demo,dc=university' | Sets base DN | 
| DATA_DIR | /var/lib/openldap/openldap-data  | Where to store database | 
| DATABASE | default  | Database name | 
| DEBUG_LEVEL | 256  | Logging level | 
| EDULDAP_ENV | development  | environment to run in | 
| EDULDAP_HOME | /opt/eduldap  | Location of EduLDAP scripts | 
| OPENLDAP_ETC | /etc/openldap  | Location of OpenLDAP configuration | 
| RESET | false  | | 
| RUN_DIR | /var/run/openldap  | | 
| SCHEMA | "core cosine nis misc pmi ppolicy dyngroup inetorgperson eduperson schac ssh"  | Space seperated list of schema to load | 
| SEED | default  | Space seperated list of seed .ldif files to load. Ships with none, default, and bigorg. | 
| SLAPD_OPTIONS | "  " | Options to pass to slapd |
| SLAPD_URLS | "ldap:/// ldapi:///"  | | 
| SOCK_DIR | /var/lib/openldap/run  | | 
| TIDY | true  | | 

### Seed data

At startup EduLDAP can initilize the LDAP directory with seed data from one or more .ldif files.

The default seed adds a "people" organisational unit and a "Barbara Jensen".

You can add your own seed file by supplying it to the container using a docker volume and specifying it in the environment:

(copying seed data requires root)

```
# docker run --rm --name tmpldap -d eduldap
<container ID is printed>
# docker cp tmpldap:/opt/eduldap/bootstrap/seeds seeds
Successfully copied 840kB to /tmp/foo/seeds
# find seeds/
seeds/
seeds/none.ldif
seeds/bigcom.ldif
seeds/default.ldif
# docker stop tmpldap
tmpldap
#
```

You can use seeds/default.ldif as a template.

Add your seed file to seeds/ and tell EduLDAP to read it by specifying it without the .ldif extension:

```
$ docker run -v ./seeds:/opt/eduldap/bootstrap/seeds -e SEED=filename -ti eduldap 
```

* volume for database storage

## Production

When using in production you can persist the LDAP database by using a docker volume:

```
version: "3.3"                                                                                  
services:                          
  ldap:   
    image: eduldap
    volumes:         
     - ldap_data:/var/lib/openldap/openldap-data 

volumes:
  ldap_data:

```

It's also strongly advised to set the environment to production to prevent the container from printing the admin password to standard out:

```
docker run -e EDULDAP_ENV=production -ti eduldap
```


