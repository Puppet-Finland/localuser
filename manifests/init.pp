#
# == Class: localuser
#
# A class for managing local system users. Supports setting up normal and admin 
# users (based on sudo rights) and managing SSH keys.
#
# == Parameters
#
# [*manage*]
#   Whether to manage local users with Puppet. Valid values are 'yes' (default) 
#   and 'no'.
# [*users*]
#   A hash containing localuser::user defined resources. Take a look at
#   the localuser::user define to see which parameters are available.
# [*groups*]
#   A hash containing group defined resources. See puppet type reference for group.
#
# == Authors
#
# Samuli Seppänen <samuli.seppanen@gmail.com>
#
# Samuli Seppänen <samuli@openvpn.net>
#
# Mikko Vilpponen <vilpponen@protecomp.fi>
#
# == License
#
# BSD-license. See file LICENSE for details.
#
class localuser
(
    $manage = 'yes',

# Automatic parameter hiera lookup is disabled, the same params are 
# fetched below with hiera_hash (deep hash merge)
#    $users = {},
#    $groups = {},
#    $ssh_keys = {},

) inherits localuser::params
{

if $manage == 'yes' {
    $users = hiera_hash('localuser::users', {})
    $groups = hiera_hash('localuser::groups', {})
    $ssh_keys = hiera_hash('localuser::ssh_keys', {})

    $defaults = {ensure => present}
    create_resources('group', $groups, $defaults)
    create_resources('localuser::user', $users, $defaults)

    $key_defaults = {'ensure' => 'present', 'type' => 'ssh-rsa'}
    create_resources('ssh_authorized_key', $ssh_keys, $key_defaults)
}
}
