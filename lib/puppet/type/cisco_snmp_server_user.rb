Puppet::Type.newtype(:cisco_snmp_server_user) do
  @doc = "This represents a router or switch SNMP User configuration."

  apply_to_device
  ensurable

  # TODO: Support SNMP V3
  # snmp-server user *user* *group* remote 127.0.0.1 udp-port 162 vrf *vrf* v3 encrypted auth md5 *pass* priv des *privpass* access *acl*

  newparam(:name) do
    desc "Name of the user"
    newvalues(/^\S+$/)
    isnamevar
    validate do |value|
      raise Exception, "TODO: This Type misses the required backend Models for now, sorry" unless defined?(RSpec)
    end
  end

  newproperty(:group) do
    desc "Group to which the user belongs"
    isrequired
    newvalues(/^\S+$/)
  end

  newproperty(:type) do
    desc "SNMP Type"
    newvalues(:remote, :v1, :v2c, :v3)
  end

  newproperty(:acl_type) do
    desc "The Type of the ACL"
    newvalues(:std, :ipv6)
  end

  newproperty(:acl) do
    desc "specify an access-list associated with this group"
    newvalues(/^\S+$/, /^\d+$/)
  end

  autorequire(:cisco_acl) do
    self[:acl]
  end

  # Since we depend on the ACL Type to validate the Value of the specified ACL
  # do it here instead
  validate do
    begin
      return unless self[:acl_type] && self[:acl]
      return unless self[:acl].to_s.match(/^\d+$/)
      acl = self[:acl].to_i
      case self[:acl_type]
      when :std
        raise Exception unless acl <= 99 && acl >= 1
      end
    rescue Exception
      raise ArgumentError, "Error while trying to validate ACL Property: #{self[:acl]} for given ACL Type: #{self[:acl_type]}"
    end
  end
end
