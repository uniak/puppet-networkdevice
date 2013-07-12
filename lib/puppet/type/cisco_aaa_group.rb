require 'puppet/util/network_device/ipcalc'
require 'puppet/util/monkey_patches_ios'
require 'puppet/util/host_list_prop'
require 'puppet/util/host_prop'
require 'puppet/util/ip_prop'

Puppet::Type.newtype(:cisco_aaa_group) do
  @doc = "This represents an Authentication, Authorization and Accounting group."

  # extend Puppet::Util::HostListProp
  extend Puppet::Util::HostProp
  extend Puppet::Util::IpProp

  apply_to_device

  ensurable

  newparam(:name) do
    desc "The configuration's name. Must always be 'running'."
    isnamevar
    newvalues(/^\w+$/)
  end

  newparam(:device_url) do
    desc "The URL at which the router or switch can be reached."
  end

  newproperty(:protocol) do
    desc "The URL at which the router or switch can be reached."
    isrequired
    newvalues(:radius, :tacacs)
  end

  newproperty(:hostname) do
    desc "The hostname of the switch."
    newvalues(/^\S+$/)
  end

  newhostprop(:server) do
    desc "The hostname or ip address of this server."
    defaultto :absent
  end

  newproperty(:acct_port) do
    desc "UDP port for RADIUS accounting server."
    newvalues(:absent, /^\d+$/)
    defaultto :absent
  end

  newproperty(:auth_port) do
    desc "UDP port for RADIUS authentication server."
    newvalues(:absent, /^\d+$/)
    defaultto :absent
  end

  newproperty(:local_authentication) do
    desc "Whether to use this server group for local login authentication"
    newvalues(:true, :false)
    defaultto :false
  end

  newproperty(:local_authorization) do
    desc "Whether to use this server group for local login authorization"
    newvalues(:true, :false)
    defaultto :false
  end
end
