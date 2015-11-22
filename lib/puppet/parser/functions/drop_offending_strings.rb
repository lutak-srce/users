#
# drop_offending_strings.rb
#

module Puppet::Parser::Functions
  newfunction(:drop_offending_strings, :type => :rvalue, :doc => <<-EOS
Removes any string from array that has offending string in it.
First param is array of strings, second is offending regex, and third
one is bool for wether to remove strings that match matched strings.

Example 1:
  drop_offending_strings([ 'adm', 'adm:', 'wheel'],':',true)
will result in;
  ['wheel']

Example 2:
  drop_offending_strings([ 'foo', 'bar', 'foobar'],'foo',false)
will result in;
  ['bar']
    EOS
  ) do |arguments|

    raise(Puppet::ParseError, "drop_offending_strings(): Wrong number of arguments " +
      "passed (#{arguments.size} " +
      'but we require 2 or 3 )') if arguments.size != 2 and arguments.size != 3

    data  = arguments[0]
    match = arguments[1]
    evict = false
    evict = arguments[2] if arguments[2]

    unless data.is_a?(Array)
      raise(Puppet::ParseError, 'drop_offending_strings(): Requires first ' +
        "argument to be an Array, you passed: #{data.class}")
    end

    unless match.is_a?(String)
      raise(Puppet::ParseError, 'drop_offending_strings(): Requires second ' +
        "argument to be a String, you passed: #{match.class}")
    end

    unless evict.is_a?(TrueClass) or evict.is_a?(FalseClass)
      raise(Puppet::ParseError, 'drop_offending_strings(): Requires third ' +
        "argument to be a TrueClass or FalseClass, you passed: #{evict.class}")
    end

    evictingdata = [] 

    data.each do |member|
      if member =~ /#{match}/
        evictingdata << member.sub(/#{match}/, '')
        data.delete(member)
      end
    end

    evictingdata = [] unless evict

    data - evictingdata
  end
end

# vim: set ts=2 sw=2 et :
