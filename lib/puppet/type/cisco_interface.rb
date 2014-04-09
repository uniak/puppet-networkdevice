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
    end
    newvalues(:absent, /^\d+$/)

    validate do |value|
      value = value.to_sym if value.is_a?(String)
      if [:undef, :absent].include?(resource.value(:port_security)) and not [:undef, :absent].include?(value)
        raise ArgumentError, "May only be set if port security is active"
      end

      self.class.value_collection.validate(value)
    end
  end

  newproperty(:port_security_aging_type) do
    desc "Which type of aging should be applied after a violation."
    defaultto do
      resource.value(:port_security) == :absent ? :absent : :inactivity
    end
    newvalues(:absent, :absolute, :inactivity)

    validate do |value|
      value = value.to_sym if value.is_a?(String)
      if [:undef, :absent].include?(resource.value(:port_security)) and not [:undef, :absolute, :absent].include?(value)
        raise ArgumentError, "May only be set if port security is active"
      end

      self.class.value_collection.validate(value)
    end
  end

  newproperty(:spanning_tree) do
    desc "Configures how this interface takes part in the spanning
    tree.

    Setting this to `leaf` will allow the device on this port to
    connect immediately, but not participate in STP negotiations. On
    IOS, this sets bpduguard, and portfast.

    Setting this to `node` allows the device to participate in
    STP negotiations, but incurs a slight delay when connecting. On
    IOS, this disables bpduguard, and portfast.

    The interface may be in the `partial` state, if the options are not
    configured consistently."

    defaultto(:node)
    newvalues(:leaf, :node, :partial)
  end

  newproperty(:spanning_tree_bpduguard) do
    desc "Don't accept BPDUs on this interface"

    defaultto do
      resource.value(:spanning_tree) == :leaf ? :present : :absent
    end

    newvalues(:present, :absent)
  end

  newproperty(:spanning_tree_guard) do
    desc "The guard mode of this interface."

    defaultto(:absent)
    newvalues(:loop, :absent, :root)

    validate do |value|
      if resource.value(:spanning_tree) != :leaf and value == :root
        raise ArgumentError, "Can set root guard only on node interfaces"
      end

      self.class.value_collection.validate(value)
    end
  end

  newproperty(:spanning_tree_cost) do
    desc "The STP port priority"

    defaultto(:absent)
    newvalues(:absent, /^\d*$/)

    validate do |value|
      if resource.value(:spanning_tree) == :leaf and value != :absent
        raise ArgumentError, "Setting a port cost for a leaf device does not make sense"
      end

      self.class.value_collection.validate(value)
    end
  end

  newproperty(:spanning_tree_port_priority) do
    desc "The STP port priority"

    defaultto(:absent)
    newvalue(:absent)
    (0..240).step(16).each {|v| newvalue(v)} # i blame cisco

    validate do |value|
      if resource.value(:spanning_tree) == :leaf and value != :absent
        raise ArgumentError, "Setting a port priority for a leaf device does not make sense"
      end

      self.class.value_collection.validate(value)
    end
  end

  newproperty(:dhcp_snooping_limit_rate) do
    desc "DHCP snooping rate limit"

    defaultto(:absent)
    newvalues(:absent, /^\d+$/)

    validate do |value|
      return if value == :absent
      raise ArgumentError, "'ip dhcp snooping limit rate' must be between 1-2048" unless value.to_i >= 1 && value.to_i <= 2048
    end
  end

  newproperty(:dhcp_snooping_trust) do
    desc "DHCP Snooping trust config"

    defaultto(:absent)
    newvalues(:absent, :present)
  end
  
  newproperty(:ip_vrf_forwarding) do
    desc "VRF forwarding function"

    defaultto(:absent)
    newvalues(:absent, /^\w+$/)
  end

  newproperty(:ip_address) do
    desc "The IP address of this interface. Format is \"IP NETMASK\"."

    defaultto(:absent)
    newvalues(:absent, /^\d+\.\d+\.\d+\.\d+ \d+\.\d+\.\d+\.\d+$/)
  end

  newproperty(:standby_delay_reload) do
    desc "HSRP initialisation delay after a configuration reload"

    defaultto(:absent)
    newvalues(:absent, /^\d+$/)
  end

end

