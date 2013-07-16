Puppet::Type.newtype(:cisco_snmp_server_community) do
  @doc = "This represents the Community Part of a router or switch SNMP
  configuration."

  apply_to_device

  ensurable

  newparam(:name) do
    desc "SNMP community string"
    isnamevar
  end

  newproperty(:perm) do
    desc "The Type of Community we are dealing with"
    newvalues(:undef, :ro, :rw)
    defaultto(:undef)
  end

  newparam(:acl_type) do
    newvalues(:std, :ext, :ipv6)
    defaultto(:std)
  end

  newproperty(:acl) do
    desc "The ACL in Word or Number Form"
    newvalues(:absent, /^\S+$/, /^\d+$/)
  end

  newproperty(:view) do
    desc "MIB view to which this community has access"
    # TODO: Autorequire the View
    newvalues(:absent, /^\S+$/)
  end

  validate do
    value = self[:acl]
    raise ArgumentError, "Must not contain Spaces" if !value.nil? and value.to_s.match(/\s/)
    return unless value.to_s.match(/^\d+$/)
    value = value.to_i
    if self[:acl_type] == :std
      raise ArgumentError, "Must be between 1-99" unless value <= 99 and value >= 1
    elsif self[:acl_type] == :ext
      raise ArgumentError, "Must be between 1300-1999" unless value <= 1999 and value >= 1300
    end
  end

  autorequire(:cisco_acl) do
    self[:acl]
  end
end
