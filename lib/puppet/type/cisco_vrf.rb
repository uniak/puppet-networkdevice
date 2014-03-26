Puppet::Type.newtype(:cisco_vrf) do
  @doc = "This represents a Virtual Routing Forwarding (VRF) configuration on a router or switch."

  apply_to_device

  ensurable

  newparam(:name) do
    isnamevar
    newvalues(/^\w+$/)
  end

  newproperty(:desc) do
    newvalues(/^\w+$/)
  end

  newproperty(:rd) do
    # allowed values are of the form X:Y, where X is either an IP or 1-65535 and Y is 1-65535
    newvalues(/^(\d+|\d+\.\d+\.\d+\.\d+):(\d+)$/)
  end

  newproperty(:export, :array_matching => :all) do
    # allowed values are of the form X:Y, where X is either an IP or 1-65535 and Y is 1-65535
    newvalues(/^(\d+|\d+\.\d+\.\d+\.\d+):(\d+)$/)
  end

  newproperty(:import, :array_matching => :all) do
    # allowed values are of the form X:Y, where X is either an IP or 1-65535 and Y is 1-65535
    newvalues(/^(\d+|\d+\.\d+\.\d+\.\d+):(\d+)$/)
  end
end
