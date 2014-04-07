require 'puppet/provider/cisco_ios'

Puppet::Type.type(:cisco_hsrp_standby_group).provide :cisco_ios, :parent => Puppet::Provider::Cisco_ios do
  desc "Cisco Switch / Router HSRP standby groups Provider for Device Configuration."
  mk_resource_methods

  def initialize(device, *args)
    super
  end

  def self.lookup(device, name)
    device.switch.hsrp_standby_group(name).params_to_hash
  end

  def flush
    device.switch.hsrp_standby_group(name).update(former_properties, properties)
    super
  end
end
