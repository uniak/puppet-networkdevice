require 'puppet/provider/cisco_ios'

Puppet::Type.type(:cisco_user).provide :cisco_ios, :parent => Puppet::Provider::Cisco_ios do
  desc "Cisco Switch / Router Provider for User Configuration."
  mk_resource_methods

  def initialize(device, *args)
    super
  end

  def self.lookup(device, name)
    device.switch.user(name).params_to_hash
  end

  def flush
    device.switch.user(name).update(former_properties, properties)
    super
  end
end
