require 'puppet/provider/cisco_ios'

Puppet::Type.type(:cisco_snmp_server_view_ios).provide :cisco_ios, :parent => Puppet::Provider::Cisco_ios do
  desc "Cisco Switch / Router Provider for SNMP Configuration."
  mk_resource_methods

  def initialize(device, *args)
    super
  end

  def self.lookup(device, name)
    device.switch.snmp_view(name).params_to_hash
  end

  def flush
    device.switch.snmp_view(name).update(former_properties, properties)
    super
  end
end
