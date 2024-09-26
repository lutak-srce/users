#
# users_is_string.rb
#

module Puppet::Parser::Functions
  newfunction(:users_is_string, :type => :rvalue, :doc => <<-EOS
Returns true if the variable passed to this function is a string.
    EOS
  ) do |arguments|

    raise(Puppet::ParseError, "users_is_string(): Wrong number of arguments " +
      "given (#{arguments.size} for 1)") if arguments.size < 1

    type = arguments[0]

    result = type.is_a?(String)

    return result
  end
end

# vim: set ts=2 sw=2 et :
