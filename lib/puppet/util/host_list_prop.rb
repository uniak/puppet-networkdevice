require 'puppet/util'

module Puppet::Util::HostListProp

  def newhostlistprop(name, options = {}, &block)
    # hostlists do array_matching all by default
    options[:array_matching] ||= :all

    newproperty(name, options) do
      # TODO: We should replace this here with a proper Class
      # the current handling is just bad
      include Puppet::Util::NetworkDevice::IPCalc

      validate do |values|
        values = [values].flatten.sort
        values.each do |value|
          self.fail "Invalid IP Address: #{value.inspect}" unless parse(value)
        end
      end

      munge do |value|
        parse(value)[1]
      end

      def insync?(is)
        self.devfail "#{self.class.name}'s should is not array" unless @should.is_a?(Array)

        return ([is].flatten.sort == [@should].flatten.sort || [is].flatten.sort == [@should].flatten.map(&:to_s).sort)
        # is.all? {|a| @should.include?(a)}
      end

      def value_to_s(value)
        value = [value].flatten.sort
        value.map{ |v| "#{v}"}.join(",")
      end

      def change_to_s(currentvalue, newvalue)
        currentvalue = value_to_s(currentvalue) if currentvalue != :absent
        newvalue = value_to_s(newvalue)
        super(currentvalue, newvalue)
      end

      class_eval(&block) if block
    end
  end
end
