#
# == Define: localuser
#
# Setup a local admin or non-admin user with or without SSH keys. Note that this 
# define requires the Puppet stdlib:
#
# <https://forge.puppetlabs.com/puppetlabs/stdlib>
#
# == Parameters
#
# [*username*]
#   Username for the user, for example 'joe'.
# [*ensure*]
#   User status, either 'present' or 'absent'. Defaults to 'present'. Affects 
#   both the user entry and the associated SSH key.
# [*password_hash*]
#   The password hash to use. On Linux, this can be obtained from /etc/shadow.
# [*comment*]
#   Comment to add to the user. Defaults to value of $username.
# [*groups*]
#   List of groups the user needs to be the member of.
# [*admin*]
#   Determine whether the user should joined to the (OS-specific) admin group. 
#   Valid values are true and false (default).
# [*shell*]
#   The default shell for the user. Defaults to 
#   ${::localuser::params::defaultshell}.
# [*ssh_key*]
#   User's public SSH key for $HOME/.ssh/authorized_keys. If left undefined, no 
#   SSH key will be installed.
# [*key_type*]
#   Type of the SSH key. Defaults to 'ssh-dss'.
#
# == Examples
#
#   localuser::user { 'john':
#       username => 'john',
#       comment => 'admin user with a SSH key',
#       password_hash => 'users_password_hash',
#       admin => true,
#       key_type => 'ssh-dss',
#       ssh_key => 'users_public_ssh_key'
#   }
#   
#   localuser::user { 'jane':
#       username => 'jane',
#       comment => 'normal user without a SSH key',
#       password_hash => 'users_password_hash',
#       admin => false,
#   }
#
# == Authors
#
# Samuli Seppänen <samuli@openvpn.net>
#
# Samuli Seppänen <samuli.seppanen@gmail.com>
#
# == License
#
# BSD-license. See file LICENSE for details.
#
define localuser::user
(
    $username,
    $ensure='present',
    $password_hash = undef,
    $comment=$username,
    $groups=[],
    $admin=false,
    $shell=undef,
    $ssh_key=undef,
    $key_type='ssh-dss',
)
{

    include ::localuser::params

    # If $shell is not defined, use the OS default
    if $shell {
        $myshell = $shell
    } else {
        $myshell = $::localuser::params::defaultshell
    }

    # Add the user to the admin group, if requested
    if $admin {
        $all_groups = concat($groups,[$::localuser::params::sudogroup])
    } else {
        $all_groups = $groups
    }

    # Create the local user
    user { $username:
        ensure     => $ensure,
        password   => $password_hash,
        shell      => $myshell,
        comment    => $username,
        home       => "${::os::params::home}/${username}",
        managehome => true,
        groups     => $all_groups,
    }

    # This trick is required to prevent the user's home directory getting 
    # removed before the SSH key is removed.
    $before = $ensure ? {
        'absent' => User[$username],
        default  => undef,
    }

    # Add user's SSH key to $HOME/.ssh/authorized_keys, if one is given
    if $ssh_key {
        ssh_authorized_key { $username:
            ensure => $ensure,
            key    => $ssh_key,
            type   => $key_type,
            name   => $username,
            user   => $username,
            before => $before,
        }
    }
}
