require 'puppet/util'

# defines a shortcut to create properties with a single IP address
# as value
module Puppet::Util::IpProp

  def newipprop(name, options = {}, &block)

    newproperty(name, options) do
      # TODO: We should replace this here with a proper Class
      # the current handling is just bad
      include Puppet::Util::NetworkDevice::IPCalc

      validate do |value|
        return true if ['absent', :absent].include?(value)
        self.fail "Invalid IP Address: #{value.inspect}" unless parse(value)
      end

      munge do |value|
        ['absent', :absent].include?(value) ? :absent : parse(value)[1]
      end

      def insync?(is)
        return ([is].flatten.sort == [@should].flatten.sort || [is].flatten.sort == [@should].flatten.map(&:to_s).sort)
      rescue => detail
        message = "Property #{name}: could not compare IP '#{[is].flatten.sort.inspect}' to '#{[@should].flatten.sort.inspect}'"
        Puppet.log_exception(detail, message)
        return false
      end

      def change_to_s(current_value, newvalue)
        begin
          if current_value == :absent
            return "defined '#{name}' as #{self.class.format_value_for_display should_to_s(newvalue)}"
          elsif newvalue == :absent
            return "undefined '#{name}' from #{self.class.format_value_for_display is_to_s(current_value)}"
          else
            return "#{name} changed #{self.class.format_value_for_display is_to_s(current_value)} to #{self.class.format_value_for_display should_to_s(newvalue)}"
          end
        rescue Puppet::Error, Puppet::DevError
          raise
        rescue => detail
          message = "Could not convert change '#{name}' to string: #{detail}"
          Puppet.log_exception(detail, message)
          raise Puppet::DevError, message
        end
      end

      class_eval(&block) if block
    end
  end
end
