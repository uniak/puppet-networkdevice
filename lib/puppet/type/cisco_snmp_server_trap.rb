Puppet::Type.newtype(:cisco_snmp_server_trap) do
  @doc = "This represents a router or switch SNMP configuration."

  apply_to_device

  newparam(:name) do
    desc "The Name of the SNMP Trap configuration. Must always be 'running'"
    newvalues(:running)
    isnamevar
    validate do |value|
      raise Exception, "TODO: This Type misses the required backend Models for now, sorry" unless defined?(RSpec)
    end
  end

  newproperty(:authentication_acl_failure) do
    desc "enable authentication traps for access list failure"
    newvalues(:present, :absent)
  end

  newproperty(:authentication_unknown_context) do
    desc "enable authentication traps for unknown context error"
    newvalues(:present, :absent)
  end

  newproperty(:authentication_vrf) do
    desc "enable authentication traps for packets on a vrf"
    newvalues(:present, :absent)
  end

  newproperty(:link_ietf) do
    desc "Use IETF standard for SNMP traps"
    newvalues(:present, :absent)
  end

  newproperty(:retry) do
    desc "number of retries for searching route"
    validate do |value|
      self.fail "'snmp-server trap retry' must be between 0-10" unless value.to_i <= 10 && value.to_i >= 0
    end
  end

  newproperty(:timeout) do
    desc "Set timeout for TRAP message retransmissions"
    validate do |value|
      self.fail "'snmp-server trap retry' must be between 1-1000" unless value.to_i <= 1000 && value.to_i >= 1
    end
  end
end
