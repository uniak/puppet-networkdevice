require 'puppet/util/network_device/ipcalc'

Puppet::Type.newtype(:cisco_radius_server) do
  @doc = "This represents a radius-server configuration on a router or switch."

  apply_to_device

  ensurable

  newparam(:name) do
    desc "IP/IPV6 address of a Radius Server"
    isnamevar

    include Puppet::Util::NetworkDevice::IPCalc

    validate do |value|
      return true if parse(value)
      self.fail "Invalid IP Address or URI: #{value.inspect}"
    end
  end

  newproperty(:acct_port) do
    desc "UDP port for RADIUS accounting server."
    newvalues(:absent, /^\d+$/)
    defaultto :absent
  end

  newproperty(:auth_port) do
    desc "UDP port for RADIUS authentication server."
    newvalues(:absent, /^\d+$/)
    defaultto :absent
  end

  newproperty(:key_type) do
    desc "Are we dealing with an UNENCRYPTED or HIDDEN Key ?"
    newvalues(:absent, 0, 7)
    isrequired
  end

  newproperty(:key) do
    desc "encryption key shared with the radius servers"
    newvalues(:absent, /^\S+$/)
    isrequired
  end

  autorequire(:cisco_aaa_group) do
    aaa = []
    if resource = catalog.resources.find { |r| r.is_a?(Puppet::Type.type(:cisco_aaa_group)) and r.should(:server) == self[:name] }
      aaa << resource
    end
    aaa
  end
end
