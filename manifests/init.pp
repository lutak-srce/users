#
# = Class: users
#
# This class adds all users with appropriate ssh keys from hiera
# value of 'useraccounts'
class users {

  # generate virtual user accounts from hiera
  $users_virtual = lookup('useraccounts', Hash, {'strategy' =>  'deep', 'merge_hash_arrays' =>  true})
  create_resources('@::Users::Account', $users_virtual)

  # realize only specific users
  $users_realize = lookup('users', {'merge' => 'unique'})
  realize (::Users::Account[$users_realize])

}
# vi:syntax=puppet:filetype=puppet:et:
