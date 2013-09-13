#
# == Class: localuser
#
# Empty class to allow including this module
#
class localuser {

# Rationale for this is explained in init.pp of the sshd module
if hiera('manage_localuser') != 'false' {
    # This is just a placeholder
}
}
