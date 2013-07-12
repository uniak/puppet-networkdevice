require 'puppet/provider/cisco_ios'

Puppet::Type.type(:cisco_vlan).provide :cisco_ios, :parent => Puppet::Provider::Cisco_ios do
  desc "Cisco Switch / Router Provider for VLAN Configuration."
  mk_resource_methods

  def initialize(device, *args)
    super
  end

  def self.lookup(device, name)
    device.switch.vlan(name).params_to_hash
  end

  def verify_vtp(device)
    # make the switch vtp primary if we try to set vlans on this switch
    unless device.switch.facts['vtp_mode'] == 'primary_server'
      self.fail("Cant set VLAN's on a VTP Client") if device.switch.facts['vtp_mode'] == 'client'
      return if device.switch.facts['vtp_mode'] == 'tranparent'
      return if device.switch.facts['vtp_version'] != '3'
      unless Puppet[:noop]
        device.switch.transport.command("end")
        device.switch.transport.command("vtp primary force")
        device.switch.facts['vtp_mode'] = 'primary_server'
      end
    end
  end

  def flush
    verify_vtp(device)
    device.switch.vlan(name).update(former_properties, properties)
    super
  end
end
