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
  $name_array = split($name, ' ')
  $comment    = $name_array[2]

  $keyoptions = regsubst($name_array[0],'^(.+),(.+)$','\1')
  if $keyoptions != '' {
    ssh_authorized_key { $comment :
      ensure  => $ensure,
      type    => $name_array[0],
      key     => $name_array[1],
      user    => $user,
      require => [ User[$user], File["${home_folder}/.ssh"], ],
    }
  }
  else {
    ssh_authorized_key { $comment :
      ensure  => $ensure,
      options => $keyoptions,
      type    => regsubst($name_array[0],'^(.+),(.+)$','\2'),
      key     => $name_array[1],
      user    => $user,
      require => [ User[$user], File["${home_folder}/.ssh"], ],
    }
  }
}
# vi:syntax=puppet:filetype=puppet:ts=4:et:
