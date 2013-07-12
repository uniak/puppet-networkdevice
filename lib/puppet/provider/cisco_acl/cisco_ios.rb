require 'puppet/provider/cisco_ios'

Puppet::Type.type(:cisco_acl).provide :cisco_ios, :parent => Puppet::Provider::Cisco_ios do
  desc "Cisco Switch / Router Provider for Device Configuration."
  mk_resource_methods

  def initialize(device, *args)
    super
  end

  def self.lookup(device, name)
    device.switch.acl(name).params_to_hash
  end

  def flush
    device.switch.acl(name).update(former_properties, properties)
    super
  end
end
