#
# = Define: users::sshkey
#
# This define adds users ssh key
define users::sshkey (
  $ensure = present,
  $user   = '',
  $home   = '',
) {

  $username = $user
  if $home == '' {
    $home_folder = "/home/${username}"
  } else {
    $home_folder = $home
  }

  # split single key into array
  $key_array = split($name, ' ')

  if $key_array[0] in [ 'ssh-dss', 'ssh-rsa', 'ecdsa-sha2-nistp256', 'ecdsa-sha2-nistp384', 'ecdsa-sha2-nistp521', 'ssh-ed25519' ] {

    ssh_authorized_key { $key_array[2] :
      ensure  => $ensure,
      type    => $key_array[0],
      key     => $key_array[1],
      user    => $user,
      require => [ User[$user], File["${home_folder}/.ssh"], ],
    }

  } elsif $key_array[1] in [ 'ssh-dss', 'ssh-rsa', 'ecdsa-sha2-nistp256', 'ecdsa-sha2-nistp384', 'ecdsa-sha2-nistp521', 'ssh-ed25519' ] {

    ssh_authorized_key { $key_array[3] :
      ensure  => $ensure,
      options => $key_array[0],
      type    => $key_array[1],
      key     => $key_array[2],
      user    => $user,
      require => [ User[$user], File["${home_folder}/.ssh"], ],
    }

  } else {

    fail("SSH key ${name} is not properly formatted. Valid SSH key types are ssh-dss, ssh-rsa, ecdsa-sha2-nistp256, ecdsa-sha2-nistp384, ecdsa-sha2-nistp521 and ssh-ed25519.")

  }
}
# vi:syntax=puppet:filetype=puppet:ts=4:et:
