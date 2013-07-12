require 'puppet/util'

# defines a shortcut to create properties with a single IP address
# or hostname as value
module Puppet::Util::HostProp

  def newhostprop(name, options = {}, &block)

    newproperty(name, options) do
      # TODO: We should replace this here with a proper Class
      # the current handling is just bad
      include Puppet::Util::NetworkDevice::IPCalc

      newvalues(:absent, /^((([a-z]|[0-9]|\-)+)\.)+([a-z])+$/i)

      validate do |value|
        return true if value == :absent
	return true if parse(value)
	return true if (/^((([a-z]|[0-9]|\-)+)\.)+([a-z])+$/i).match value

        self.fail "Invalid Hostname: #{value.inspect}"
      end

      munge do |value|
	if value == :absent
	  :absent
	elsif parse(value)
	  parse(value)[1]
	else
	  value
	end
      end

      class_eval(&block) if block
    end
  end
end
