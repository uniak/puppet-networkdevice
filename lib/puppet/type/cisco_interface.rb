Puppet::Type.newtype(:cisco_interface) do
  @doc = "This represents a router or switch interface."

  apply_to_device

  newparam(:name) do
    desc "The interface's name."
    newvalues(/^\w+[Ee]thernet\S+$/, /[Vv]lan\d+$/, /[Tt]unnel\d+$/)
    isnamevar
  end

  newproperty(:description) do
    desc "The description of the interface."
    isrequired
    newvalues(/\A[^\n]*\z/m)
  end

  newproperty(:mode) do
    desc "Set trunking mode of the interface."
    defaultto(:absent)
    newvalues(:absent, :access, :dot1q, :dynamic, :private, :trunk)
  end

  newproperty(:access) do
    desc "Set VLAN when interface is in access mode"
    defaultto(:absent)
    newvalues(:absent, :dynamic, /^\d+$/)

    validate do |value|
      if resource.value(:mode) == :access and value == :absent
        raise ArgumentError, "Must set vlan number or sticky if mode is access"
      elsif resource.value(:mode) != :access and value != :absent
        raise ArgumentError, "May only be set if mode is access"
      end

      self.class.value_collection.validate(value)
    end
  end

  newproperty(:trunk_allowed_vlan) do
    desc "List of allowed VLANs on this interface"
    defaultto(:absent)
    newvalues(:absent, /^(\d+(-\d+)?,)*\d+(-\d+)?$/)

    validate do |value|
      if resource.value(:mode) != :trunk and value != :absent
        raise ArgumentError, "May only be set if mode is trunk"
      end

      self.class.value_collection.validate(value)
    end
  end

  newproperty(:trunk_encapsulation) do
    desc "Set trunking encapsulation when interface is in trunking mode"
    defaultto(:absent)
    newvalues(:absent, :dot1q, :isl, :negotiate)

    validate do |value|
      if resource.value(:mode) == :trunk and value == :absent
        raise ArgumentError, "Must set encapsulation if mode is trunk"
      elsif resource.value(:mode) != :trunk and value != :absent
        raise ArgumentError, "May only be set if mode is trunk"
      end

      self.class.value_collection.validate(value)
    end
  end

  newproperty(:trunk_native_vlan) do
    desc "Set native VLAN when interface is in trunking mode"
    defaultto(:absent)
    newvalues(:absent, /^\d+$/)

    validate do |value|
      if resource.value(:mode) != :trunk and value != :absent
        raise ArgumentError, "May only be set if mode is trunk"
      end

      self.class.value_collection.validate(value)
    end
  end

  newproperty(:negotiate) do
    desc "Whether or not this interface will engage in any negotiations"
    defaultto(true)
    newvalues(true,false)
  end

  newproperty(:port_security) do
    desc "How this interface should react to port security
    violations."
    defaultto(:absent)
    newvalues(:absent, :protect, :restrict, :shutdown, :shutdown_vlan)
  end

  newproperty(:port_security_mac_address) do
    desc "The allowed MAC address on this interface"
    defaultto do
      resource.value(:port_security) == :absent ? :absent : :sticky
    end
    newvalues(:absent, :sticky, /^([0-9a-fA-F]{2}\:){5}[0-9a-fA-F]{2}$/)

    validate do |value|
      value = value.to_sym if value.is_a?(String)
      if resource.value(:port_security) == :absent and value.to_sym != :absent
        raise ArgumentError, "May only be set if port security is active"
      end

      self.class.value_collection.validate(value)
    end
  end

  newproperty(:port_security_aging_time) do
    desc "How long a port should stay locked after a violation."
    defaultto do
      resource.value(:port_security) == :absent ? :absent : 1
