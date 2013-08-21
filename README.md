Redmine Gitolite script
=======================

This script consumes Redmine group membership from the Redmine api and generates gitolite configs.

Dependencies
============

Requires perl, WWW::Curl::Easy, YAML, JSON, Makefile.pl (or equivalent) coming soon

Ubuntu Precise
--------------

    sudo apt-get install libwww-curl-perl libyaml libjson-perl

Usage
=====

Copy the config.yaml.example to config.yaml and tune to your needs

Create a Redmine api key by following the instructions [here](http://www.redmine.org/projects/redmine/wiki/Rest_api "Redmine API Documentation")

The script will print to standard out (write to file coming soon)

    ./gitolite-remine.pl > gitolite.conf


Example gitolite.conf file
--------------------------

    cat gitolite.conf

    repo    gitolite-admin
            RW+     =   gitolite@example.org

            include "aliases.conf"
            include "projects.conf"


Tests
=====

There are no tests yet. Coming soon.


License & Copyright
===================

(C) 2013 Spencer Krum for the PSU Computer Action Team

Released under the Apache 2.0 License
