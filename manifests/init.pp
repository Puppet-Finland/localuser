#
# == Class: localuser
#
# A class for managing local system users. Supports setting up normal and admin 
# users (based on sudo rights) and managing SSH keys.
#
# == Parameters
#
# [*users*]
#   A hash containing localuser::user defined resources. Take a look at
#   the localuser::user define to see which parameters are available.
#
# == Authors
#
# Samuli Seppänen <samuli.seppanen@gmail.com>
#
# Samuli Seppänen <samuli@openvpn.net>
#
# == License
#
# BSD-license. See file LICENSE for details.
#
class localuser
(
    $users = {}

) inherits localuser::params
{

# Rationale for this is explained in init.pp of the sshd module
if hiera('manage_localuser', 'true') != 'false' {
    create_resources('localuser::user', $users)
}
}
