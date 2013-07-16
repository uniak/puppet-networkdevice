Puppet::Type.newtype(:cisco_snmp_server_view) do
  @doc = "This represents a router or switch SNMP configuration."

  apply_to_device
  ensurable

  newparam(:name) do
    desc "Name of the view"
    newvalues(/^\S+$/)
    isnamevar
    validate do |value|
      raise Exception, "TODO: This Type misses the required backend Models for now, sorry" unless defined?(RSpec)
    end
  end

  newproperty(:excluded_mibs, :array_matching => :all) do
    desc "MIB family is excluded from the view"
    newvalues(/^\S+$/)
  end

  newproperty(:included_mibs, :array_matching => :all) do
    desc "MIB family is included in the view"
    newvalues(/^\S+$/)
  end

end
