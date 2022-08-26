#
# = Define: users::account
#
# Creates all the missing stuff for user logged in through AD
define users::adaccount (
  $useraccounts = {},
){

  $ad_user = regsubst($name, '.*\/', '')
  $ad_home = "/home/${name}"

  file { "${ad_home}/.ssh" :
    ensure => directory,
    owner  => $ad_user,
    mode   => '0700',
  }

  if has_key($useraccounts, $ad_user) {
    ::users::adaccount::sshkey { $useraccounts[$ad_user]['sshkeys'] :
      user => $ad_user,
      home => $ad_home,
    }
  }

}
# vi:syntax=puppet:filetype=puppet:ts=4:et:
