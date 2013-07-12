Puppet::Type.newtype(:cisco_vlan) do
  @doc = "This represents a vlan configuration on a router or switch."

  apply_to_device

  ensurable

  newparam(:name) do
    isnamevar
    newvalues(/^\d+$/)
  end

  newproperty(:desc) do
    newvalues(/^\S+$/)
  end
end
