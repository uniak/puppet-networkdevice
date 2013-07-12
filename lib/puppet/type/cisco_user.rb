Puppet::Type.newtype(:cisco_user) do
  @doc = "This represents a username configuration on a router or switch."

  apply_to_device

  ensurable

  newparam(:name) do
    desc "User name"
    isnamevar
    newvalues(/^\S+$/)
  end

  newproperty(:privilege) do
    newvalues(/^\d+$/)

    validate do |value|
      raise ArgumentError, "Must only contain Integers" unless value.to_s.match(/^\d+$/)
      raise ArgumentError, "Must be between 0-15" unless value.to_i >= 0 and value.to_i <= 15
    end
  end

  newproperty(:password_type) do
    desc "Are we dealing with an UNENCRYPTED or HIDDEN Key ?"
    newvalues(:absent, 0, 7)
    isrequired
  end

  newproperty(:password) do
    desc "The Password"
    newvalues(/^\S+$/)
    isrequired
  end
end
