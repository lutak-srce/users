#
# = Class: users
#
# This class adds all users with appropriate ssh keys from hiera
# value of 'useraccounts'
class users {

  # generate virtual user accounts from hiera
  $users_virtual = hiera_hash('useraccounts', {})
  create_resources('@::Users::Account', $users_virtual)

  # realize only specific users
  $users_realize = hiera_array('users',[])
  realize (::Users::Account[$users_realize])

}
# vi:syntax=puppet:filetype=puppet:et:
