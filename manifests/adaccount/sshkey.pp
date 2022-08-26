#
# = Define: users::adaccount::sshkey
#
# This define adds users ssh key
define users::adaccount::sshkey (
  $ensure = present,
  $user,
  $home,
) {
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
      require => File["${home}/.ssh"],
    }
  }
  else {
    ssh_authorized_key { $comment :
      ensure  => $ensure,
      options => $keyoptions,
      type    => regsubst($name_array[0],'^(.+),(.+)$','\2'),
      key     => $name_array[1],
      user    => $user,
      require => File["${home}/.ssh"],
    }
  }
}
# vi:syntax=puppet:filetype=puppet:ts=4:et:
