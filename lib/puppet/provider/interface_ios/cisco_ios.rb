require 'puppet/provider/cisco_ios'

Puppet::Type.type(:interface_ios).provide :cisco_ios, :parent => Puppet::Provider::Cisco_ios do
  desc "Cisco Switch / Router Interface Provider for Device Configuration."
  mk_resource_methods

  def initialize(device, *args)
    super
  end

  def self.lookup(device, name)
    device.switch.interface(name).params_to_hash
  end

  def flush
    device.switch.interface(name).update(former_properties, properties)
    super
  end
end
