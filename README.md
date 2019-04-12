# EduLDAP

A simple OpenLDAP service for education use, designed to be quick to use in development, 
and a base for production services.

This is an early version, still very much in-development. 

## Advantages

* Small size: 10MB
* Few layers
* Alpine's security architecture
* Low memory usage (with ulimit options, see below)
* Uses LDIF configuration backend
* Education schemas as used by SAML/Shibboleth IdPs: eduPerson, SCHAC
* Includes variety of ready-made directories for quick testing
* Easy customisation
* Even a few tests.

## Quickstart



## Misc


 * add --ulimit nofile=1024:1024 to docker run to stop runaway memory usage
