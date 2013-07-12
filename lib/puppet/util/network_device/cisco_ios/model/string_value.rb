require 'erb'
require 'puppet/util/network_device/cisco_ios/model'
require 'puppet/util/network_device/cisco_ios/model/scoped_value'

class Puppet::Util::NetworkDevice::Cisco_ios::Model::StringValue < Puppet::Util::NetworkDevice::Cisco_ios::Model::ScopedValue

  # Make sure that whoever calls this methods receives an error and
  # we don't perform a lookup in the inheritance chain
  undef_method :add, :remove, :update

  [:fragment, :supported].each do |meth|
    define_method(meth) do |*args, &block|
      # return the current value if we are called like an accessor
      return instance_variable_get("@#{meth}".to_sym) if args.empty? && block.nil?
      # set the new value if there is any
      instance_variable_set("@#{meth}".to_sym, (block.nil? ? args.first : block))
    end
  end

  def get_fragment
    return fragment.call if fragment.is_a?(Proc)
    self.value == :absent ? nil : ERB.new(fragment).result(binding)
  end

  # Since we dont have the #add and #remove methods provide something else to make sure
  # that the param is supported on the hw /sw platform we are on
  def supported?
    !!supported
  end

  def parse(txt)
    txt = extract_scope(txt)
    if txt.nil? || txt.empty?
      Puppet.debug("Scope #{scope} not found for Param #{name}")
      return
      self.evaluated = true
    end
    if self.match.is_a?(Proc)
      self.value = self.match.call(txt)
    else
      self.value = txt.scan(self.match).flatten[self.idx]
    end
    self.evaluated = true
  end
end
