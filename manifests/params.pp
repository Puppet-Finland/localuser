#
# == Class: localuser::params
#
# Defines some variables based on the operating system
#
class localuser::params {

    include ::os::params

    case $::osfamily {
        'RedHat': { }
        'Debian': { }
        'FreeBSD': { }
        default: {
            fail("Unsupported OS: ${::osfamily}")
        }
    }
}
