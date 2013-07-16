Puppet::Type.newtype(:cisco_snmp_server_group) do
  @doc = "This represents the Group Part of a router or switch SNMP
  configuration."

  apply_to_device

  ensurable

  # TODO: ipv6 ACL Support

  newparam(:name) do
    desc "Name of the group"
    isnamevar
    validate do |value|
      raise Exception, "TODO: This Type misses the required backend Models for now, sorry" unless defined?(RSpec)
    end
  end

  newproperty(:model) do
    desc "The Security Model to use"
    newvalues(:v1, :v2c, :v3)
    isrequired
  end

  newproperty(:access) do
    desc "specify an access-list associated with this group"
    # TODO: Autorequire the ACL
    newvalues(/^[1-9][0-9]?$/, /^[a-zA-Z-]+$/)
  end

  newproperty(:context) do
    desc "specify a context to associate these views for the group"
    newvalues(/^\S+$/)
  end

  newproperty(:notify_view) do
    desc "specify a notify view for the group"
    # TODO: Autorequire the View
    newvalues(/^\S+$/)
  end

  newproperty(:read_view) do
    desc "specify a read view for the group"
    # TODO: Autorequire the View
    newvalues(/^\S+$/)
  end

  newproperty(:write_view) do
    desc "specify a write view for the group"
    # TODO: Autorequire the View
    newvalues(/^\S+$/)
  end
end
