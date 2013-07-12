Puppet::Type.newtype(:cisco_snmp_server_ios) do
  @doc = "This represents a router or switch SNMP configuration."

  apply_to_device

  # TODO: Seperate Type
  # snmp-server group
  # snmp-server trap
  # snmp-server user
  # snmp-server view

  newparam(:name) do
    desc "The Name of the SNMP configuration. Must always be 'running'"
    newvalues(:running)
    isnamevar
  end

  newproperty(:chassis_id) do
    desc "The Chassis ID of the Switch."
    newvalues(:absent, /^\S+$/)
  end

  newproperty(:contact) do
    desc "The Contact to report."
    newvalues(:absent, /^\S+$/)
  end

  newproperty(:enable_traps, :array_matching => :all) do
    desc "The SNMP Traps to enable on the Switch."
    newvalues(:absent, "auth-framework", "bridge", "cef", "cluster",
              "config", "config-copy", "config-ctid", "copy-config",
              "cpu", "dot1x", "eigrp", "energywise", "entity", "envmon",
              "errdisable", "event-manager", "flash", "fru-ctrl", "hsrp",
              "ipmulticast", "license", "mac-notification", "ospf", "pim",
              "port-security", "power-ethernet", "rtr", "snmp", "stackwise",
              "storm-control", "stpx", "syslog", "transceiver all", "tty",
              "vlan-membership", "vlancreate", "vlandelete", "vstack", "vtp")

    munge do |value|
      if value == :absent
        value
      else
        value.to_s
      end
    end

    def insync?(is)
      return ([is].flatten.sort == [@should].flatten.sort || [is].flatten.sort == [@should].flatten.map(&:to_s).sort)
    end
  end

  newproperty(:engineid_local) do
    desc "The engine ID octet string."
    newvalues(:absent, /^\S+$/)
  end

# TODO: Should be extracted into a new Type
#  newproperty(:engineid_remote) do
#    desc "The  Hostname or IP/IPv6 address of SNMP notification host"
#    newvalues(:absent, /^\S+$/)
#  end

# TODO: protocol
  newproperty(:file_transfer_access_group) do
    desc "Access control for file transfers"
    # TODO: Autorequire the ACL
    newvalues(:absent, /^\S+$/, /^\d+$/)
  end

  newproperty(:ifindex_persist) do
    desc "Enable ifindex persistence"
    newvalues(:present, :absent)
    defaultto(:absent)
  end

  newproperty(:inform_pending) do
    desc "Set number of unacked informs to hold"
    newvalues(:absent, /\d+/)
    validate do |value|
      self.fail "'snmp-server inform pending' must be between 1-4294967295" unless value.to_i <= 4294967295 && value.to_i >= 1
    end
  end

  newproperty(:inform_retries) do
    desc "Set retry count for informs"
    newvalues(:absent, /\d+/)
    validate do |value|
      self.fail "'snmp-server inform retries' must be between 1-100" unless value.to_i <= 100 && value.to_i >= 1
    end
  end

  newproperty(:inform_timeout) do
    desc "Set timeout for informs"
    newvalues(:absent, /\d+/)
    validate do |value|
      self.fail "'snmp-server inform timeout' must be between 1-4294967295" unless value.to_i <= 4294967295 && value.to_i >= 1
    end
  end

  newproperty(:ip_dscp) do
    desc "IP DSCP value for SNMP traffic"
    newvalues(:absent, /\d+/)
    validate do |value|
      self.fail "'snmp-server ip dscp' must be between 0-63" unless value.to_i <= 63 && value.to_i > 0
    end
  end

  newproperty(:ip_precedence) do
    desc "IP Precedence value for SNMP traffic"
    newvalues(:absent, /\d+/)
    validate do |value|
      self.fail "'snmp-server ip precedence' must be between 0-7" unless value.to_i <= 7 && value.to_i > 0
    end
  end

  newproperty(:location) do
    desc "The physical location of this node"
    newvalues(/^\S+$/)
  end

  newproperty(:manager) do
    desc "Activate / Deactivate the SNMP Manager"
    newvalues(:present, :absent)
    defaultto(:absent)
  end

  newproperty(:manager_session_timeout) do
    desc "Timeout value for destroying sessions"
    validate do |value|
      self.fail "'snmp-server manager session-timeout' must be between 10-2147483" unless value.to_i <= 2147483 && value.to_i >= 10
    end
  end

  newproperty(:packetsize) do
    desc "Packet size"
    validate do |value|
      self.fail "'snmp-server packetsize' must be between 484-17892" unless value.to_i <= 17892 && value.to_i >= 484
    end
  end

  newproperty(:queue_length) do
    desc "Message queue length for each TRAP host"
    validate do |value|
      self.fail "'snmp-server queue-length' must be between 1-5000" unless value.to_i <= 5000 && value.to_i >= 1
    end
  end

  newproperty(:source_interface_informs) do
    desc "source interface for informs"
    # TODO: Autorequire the Interface
    newvalues(/^\S+$/)
  end

  newproperty(:source_interface_traps) do
    desc "source interface for traps"
    # TODO: Autorequire the Interface
    newvalues(/^\S+$/)
  end

  newproperty(:system_shutdown) do
    desc "Enable use of the SNMP reload command"
    newvalues(:absent, :present)
    defaultto(:absent)
  end

  newproperty(:tftp_server_list) do
    desc "Limit TFTP servers used via SNMP"
    # TODO: Autorequire the ACL
    newvalues(/^\S+$/, /^\d+$/)
  end

  newproperty(:trap_source) do
    desc "Assign an interface for the source address of all traps"
    # TODO: Autorequire the Interface
    newvalues(/^\S+$/)
  end

  newproperty(:trap_timeout) do
    desc "Set timeout for TRAP message retransmissions"
    validate do |value|
      self.fail "'snmp-server trap-timeout' must be between 1-1000" unless value.to_i <= 1000 && value.to_i >= 1
    end
  end

end
