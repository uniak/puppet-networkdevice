require 'puppet/util/network_device/ipcalc'

Puppet::Type.newtype(:cisco_snmp_server_host) do
  @doc = "This represents the Host Part of a router or switch SNMP
  configuration."

  apply_to_device

  ensurable

  newparam(:name) do
    desc "IP/IPV6 address of SNMP notification host or
    HTTP address of XML notification host"
    isnamevar

    include Puppet::Util::NetworkDevice::IPCalc

    validate do |value|
      return true if value.match(/http:\/\/\S+(?::\d+)?\/\S*/)
      return true if parse(value)
      self.fail "Invalid IP Address or URI: #{value.inspect}"
    end
  end

  newproperty(:community) do
    desc "SNMPv1/v2c community string or SNMPv3 user name"
    newvalues(/^\S+$/)
    isrequired
  end

  newproperty(:udp_port) do
    desc "The notification host's UDP port number (default port 162)"
    newvalues(:absent, /^\d+$/)
    validate do |value|
      self.fail "'snmp-server host * * udp-port' must be between 0-65535" unless value.to_i <= 65535 && value.to_i >= 0
    end
  end

  autorequire(:cisco_snmp_server_community) do
    self[:community]
  end

# TODO: Implent the following Propertys

#  # TODO: informs_community
#  # TODO: informs_version
#  newproperty(:informs) do
#    # TODO: Autorequire the SNMP Community
#    desc "Send Inform messages to this host"
#    newvalues(:auth_framework, :bridge, :cef, :cluster, :config, :config_copy,
#              :config_ctid, :copy_config, :cpu, :dot1x, :eigrp, :energywise,
#              :entity, :envmon, :errdisable, :event_manager, :flash,
#              :fru_ctrl, :hsrp, :ipmulticast, :license, :mac_notification,
#              :ospf, :pim, :port_security, :power_ethernet, :rtr, :snmp,
#              :stackwise, :storm_control, :stpx, :syslog, :transceiver,
#              :tty, :vlan_membership, :vlancreate, :vlandelete, :vstack, :vtp)
#  end
#
#  # TODO: traps_community
#  # TODO: traps_version
#  newproperty(:traps, :array_matching => :all) do
#    # TODO: Autorequire the SNMP Community
#    desc "Send Trap messages to this host"
#    newvalues(:auth_framework, :bridge, :cef, :cluster, :config, :config_copy,
#              :config_ctid, :copy_config, :cpu, :dot1x, :eigrp, :energywise,
#              :entity, :envmon, :errdisable, :event_manager, :flash,
#              :fru_ctrl, :hsrp, :ipmulticast, :license, :mac_notification,
#              :ospf, :pim, :port_security, :power_ethernet, :rtr, :snmp,
#              :stackwise, :storm_control, :stpx, :syslog, :transceiver,
#              :tty, :vlan_membership, :vlancreate, :vlandelete, :vstack, :vtp)
#  end
#
#  newproperty(:version) do
#    desc "SNMP version to use for notification messages"
#    newvalues(:v1, :v2c, :v3)
#
#    munge do |value|
#      # The internal representation of the SNMP Version differs
#      # from Command to Command, use the v* Expression everywhere and munge
#      # the value into the expected format
#      value.to_s.gsub(/^v/, '')
#    end
#  end
#
#  newproperty(:vrf) do
#    desc "VPN Routing instance for this host"
#    newvalues(:undef, :absent, /^\S+$/)
#  end
end
