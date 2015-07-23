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
# [*password*]
#   The password (not a hash) to use. The hash will be auto-generated and passed 
#   on to the user resource. This parameter is overridden by the $password_hash 
#   parameter if it is defined.
# [*salt*]
#   A (random) string to pass to the the password hashing function. Only 
#   required if $password parameter is defined.
# [*password_hash*]
#   The password hash to use. On Linux, this can be obtained from /etc/shadow. 
#   Note that one of $password_hash or $password has to be defined or this 
#   resource will fail to apply.
# [*comment*]
#   Comment to add to the user. Defaults to value of $username.
# [*groups*]
#   List of groups the user needs to be the member of.
# [*admin*]
#   Determine whether the user should joined to the (OS-specific) admin group. 
#   Valid values are true and false (default).
# [*shell*]
#   The default shell for the user. Defaults to 
#   $::os::params::interactive_shell.
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
#       password => 'verysecret',
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
    $password = undef,
    $salt = undef,
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
        $myshell = $::os::params::interactive_shell
    }

    # Add the user to the admin group, if requested
    if $admin {
        $all_groups = concat($groups,[$::os::params::sudogroup])
    } else {
        $all_groups = $groups
    }

    # Check if a password hash has been given as a parameter. If not, hash the 
    # given plain-text password with the salt. Note that the salt is not 
    # generated on the fly in a function because that would trigger regeneration 
    # of the password hash on every run, even if the password itself would 
    # always remain the same. If no password is given, then do not set password 
    # for the user.
    if $password_hash {
        $hash = $password_hash
    } elsif ( $password and $salt ) {
        $hash = pw_hash($password, 'SHA-512', $salt)
    } else {
        $hash = undef
    }

    # Determine the correct home directory
    $homedir = $username ? {
        'root'  => $::os::params::root_home,
        default => "${::os::params::home}/${username}",
    }

    # Create the local user
    user { $username:
        ensure     => $ensure,
        password   => $hash,
        shell      => $myshell,
        comment    => $username,
        home       => $homedir,
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
