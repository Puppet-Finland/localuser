# localuser

A puppet module to manage admin and non-admin users with or without SSH keys

# Module usage

* [Class: localuser](manifests/init.pp)
* [Define: localuser::user](manifests/user.pp)

# Dependencies

See [metadata.json](metadata.json).

# Operating system support

This module has been tested on

* Debian 7 and 8
* Ubuntu 12.04 and 14.04
* CentOS 6 and 7
* Fedora 21
* FreeBSD 10

Any *NIX-style operating system should work out of the box or with small 
modifications.

For details see [params.pp](manifests/params.pp).
