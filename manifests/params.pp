#
# == Class: localuser::params
#
# Defines some variables based on the operating system
#
class localuser::params {

    case $::osfamily {
        'RedHat': {
            $admingroup = 'wheel'
         }
        'Debian': {
            $admingroup = 'sudo'

        }
        default: {
            $admingroup = 'sudo'
        }
    }
}
