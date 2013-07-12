require 'puppet/util/network_device/ipcalc'
require 'puppet/util/monkey_patches_ios'
require 'puppet/util/host_list_prop'
require 'puppet/util/host_prop'
require 'puppet/util/ip_prop'

Puppet::Type.newtype(:cisco_line) do
  @doc = "This represents a terminal line on the switch."

  # extend Puppet::Util::HostListProp
  extend Puppet::Util::HostProp
  extend Puppet::Util::IpProp

  apply_to_device

  ensurable

  newparam(:name) do
    desc "The line's name."
    isnamevar
    newvalues(/^(vty|con) \d+$/)
  end

  newparam(:device_url) do
    desc "The URL at which the router or switch can be reached."
  end

  newproperty(:access_class) do
    desc "The access-class for this line"
    newvalues(:absent, /^.*$/)
  end

  newproperty(:exec_timeout) do
    desc "The exec-timeout for this line (in seconds)."
    newvalues(:absent, /^\d+$/)
    defaultto :absent

    munge do |val|
      if val == :absent
        val
      else
        val.to_i
      end
    end
  end

  newproperty(:logging) do
    desc "wether or not this line has synchronous logging"
    newvalues(:absent, :synchronous)
    defaultto :synchronous
  end

  newproperty(:transport) do
    desc "The accepted protocol on this line"
    newvalues(:all, :none, :ssh, :telnet)
    defaultto :ssh
  end
end
