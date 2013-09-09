#
# == Class: localuser::params
#
# Defines some variables based on the operating system
#
class localuser::params {

    case $::osfamily {
        'RedHat': {
            $sudogroup = 'wheel'
            $defaultshell = '/bin/bash'
        }
        'Debian': {
            $sudogroup = 'sudo'
            $defaultshell = '/bin/bash'
        }
        'FreeBSD': {
            $sudogroup = 'wheel'
            $defaultshell = '/bin/csh'
        }
        default: {
            $sudogroup = 'sudo'
            $defaultshell = '/bin/bash'
        }
    }
}
