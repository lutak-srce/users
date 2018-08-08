#
# = Define: users::account
#
# This define adds user account to local system
#
define users::account (
  $ensure         = present,
  $comment        = '',
  $uid            = '',
  $groups         = '',
  $shell          = '/bin/bash',
  $password       = '',
  $sshkeys        = [],
  $recurse        = false,
  $membership     = inclusive,
  $home           = '',
  $resetpw        = true,
  $purge_home     = false,
  $purge_ssh_keys = false,
) {

  $username = $name
  if $home == '' {
    $home_folder = "/home/${username}"
  } else {
    $home_folder = $home
  }

  # parse groups, in case we use multiple OS-es
  if is_array( $groups ) {
    $parsed_groups = drop_offending_strings($groups,'^!',true)
  } elsif is_hash ( $groups ) {
    $parsed_groups = drop_offending_strings($groups[$::osfamily],'^!',true)
  } else {
    $parsed_groups = undef
  }

  # parse shells, in case we use multiple OS-es
  if is_string( $shell ) {
    $parsed_shell = $shell
  } elsif is_hash ( $shell ) {
    $parsed_shell = $shell[$::osfamily]
  }

  # check if password is set
  if $password != '' {
    $password_real = $password
  } else {
    $password_real = undef
    if $resetpw {
      exec { "setpassonlogin_${username}":
        command     => "/usr/sbin/usermod -p '' ${username} && /usr/bin/chage -d 0 ${username}",
        onlyif      => "/bin/grep ${username} /etc/shadow | /usr/bin/cut -f 2 -d : | /bin/grep -q '!'",
        refreshonly => true,
        subscribe   => User[$username],
        require     => User[$username],
      }
    }
  }

  # If ensure is set to absent, move home dir ownership to root
  if ( ensure == 'absent' ) {
    User[$username] -> Group[$username]
    $home_owner = 'root'
    $home_group = 'root'
    if ( $purge_home ) {
      $home_ensure = 'absent'
    } else {
      $home_ensure = undef
    }
  } else {
    Group[$username] -> User[$username]
    $home_owner  = $username
    $home_group  = $username
    $home_ensure = 'directory'
  }

  # Default user settings
  user { $username:
    ensure         => $ensure,
    uid            => $uid,
    gid            => $uid,
    groups         => $parsed_groups,
    membership     => $membership,
    comment        => $comment,
    home           => $home_folder,
    shell          => $parsed_shell,
    password       => $password_real,
    allowdupe      => false,
    managehome     => true,
    purge_ssh_keys => $purge_ssh_keys,
  }

  # Default group settings
  group { $username:
    ensure    => $ensure,
    gid       => $uid,
    allowdupe => false,
  }

  file { $home_folder:
    ensure  => $home_ensure,
    owner   => $home_owner,
    group   => $home_group,
    recurse => $recurse,
    replace => true,
    force   => true,
    require => User[$username],
  }

  file { "${home_folder}/.bash_history":
    ensure  => file,
    mode    => '0600',
    owner   => $home_owner,
    group   => $home_group,
    require => File[$home_folder],
  }

  file { "${home_folder}/.ssh":
    ensure  => $home_ensure,
    owner   => $home_owner,
    group   => $home_group,
    mode    => '0700',
    require => File[$home_folder],
  }

  # add sshkeys to user account if keys are defined at hiera
  ::users::sshkey { $sshkeys :
    user => $username,
    home => $home_folder,
  }

}
# vi:syntax=puppet:filetype=puppet:ts=4:et:
