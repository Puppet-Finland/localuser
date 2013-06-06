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
# [*status*]
#   User status, either 'present' or 'absent'. Defaults to 'present'. Affects 
#   both the user entry and the associated SSH key.
# [*password_hash*]
#   The password hash to use. On Linux, this can be obtained from /etc/shadow.
# [*comment*]
#   Comment to add to the user. Defaults to value of $username.
# [*groups*]
#   List of groups the user needs to be the member of.
# [*admin*]
#   Determine whether the user is an admin. Valid values 'yes' and 'no', 
#   defaults to 'no'. In practice, adds the user to the OS-specific admin group 
#   defined in localuser::params.
# [*shell*]
#   The default shell for the user. Defaults to '/bin/bash'.
# [*ssh_key*]
#   User's public SSH key for $HOME/.ssh/authorized_keys. If left undefined, no 
#   SSH key will be installed.
# [*key_type*]
#   Type of the SSH key. Defaults to 'ssh-dss'.
#
# == Examples
#
# localuser::user { 'john':
#   username => 'john',
#   comment => 'admin user with a SSH key',
#   password_hash => 'users_password_hash',
#   admin => 'yes',
#   key_type => 'ssh-dss',
#   ssh_key => 'users_public_ssh_key'
# }
#
# localuser::user { 'jane':
#   username => 'jane',
#   comment => 'normal user without a SSH key',
#   password_hash => 'users_password_hash',
#   admin => 'no',
# }
#
# == Authors
#
# Samuli Seppänen <samuli@openvpn.net>
# Samuli Seppänen <samuli.seppanen@gmail.com>
#
# == License
#
# BSD-lisence
# See file LICENSE for details
#
define localuser::user
(
    $username,
    $status='present',
    $password_hash,
    $comment="$username",
    $groups=[],
    $admin='no',
    $shell='/bin/bash',
    $ssh_key='',
    $key_type='ssh-dss',
)
{

    include localuser::params

    # Add the user to the admin group, if requested
    if $admin == 'yes' {
        $all_groups = concat($groups,["$::localuser::params::admingroup"])
    } else {
        $all_groups = $groups
    }

    # Create the local user
    user { "$username":
        password => "$password_hash",
        shell => $shell,
        comment => "$username",
        home => "/home/$username",
        managehome => true,
        groups => $all_groups,
        ensure => $status,
    }

    # Add user's SSH key to $HOME/.ssh/authorized_keys, if one is given
    if $ssh_key == '' {
        # It seems "if not" and "if !" do not work, so this stub is needed.
    } else {
        ssh_authorized_key { "$username":
            ensure => $status,
            key => $ssh_key,
            type => $key_type,
            name => $username,
            user => $username
        }
    }
}
