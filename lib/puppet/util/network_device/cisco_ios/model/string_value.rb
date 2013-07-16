require 'erb'
require 'puppet/util/network_device/value_helper'
require 'puppet/util/network_device/cisco_ios/model'
require 'puppet/util/network_device/cisco_ios/model/scoped_value'

class Puppet::Util::NetworkDevice::Cisco_ios::Model::StringValue < Puppet::Util::NetworkDevice::Cisco_ios::Model::ScopedValue

  extend Puppet::Util::NetworkDevice::ValueHelper
  # Make sure that whoever calls this methods receives an error and
  # we don't perform a lookup in the inheritance chain
  undef_method :add, :remove, :update

  define_value_method [:fragment, :supported]

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
