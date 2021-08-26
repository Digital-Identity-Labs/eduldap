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

## EduLDAP commands and bootstrapping

## Usage

### Configuring the directory init stage

### Using directly with the commandline

### Using as a base image

### Using with Docker compose

### Using in production 

## Misc

## Development


