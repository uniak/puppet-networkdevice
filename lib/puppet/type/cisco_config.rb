require 'puppet/util/network_device/ipcalc'
require 'puppet/util/monkey_patches_ios'
require 'puppet/util/host_list_prop'
require 'puppet/util/ip_prop'

Puppet::Type.newtype(:cisco_config) do
  @doc = "This represents a router or switch configuration. There can be only
  one instance of this and it has to be called 'running'."

  extend Puppet::Util::HostListProp
  extend Puppet::Util::IpProp

  apply_to_device

  newparam(:name) do
    desc "The configuration's name. Must always be 'running'."
    newvalues(:running)
  end

  newproperty(:hostname) do
    desc "The hostname of the switch."
    newvalues(/^\S+$/)
  end

  newproperty(:ip_domain_name) do
    # TODO: REVIEW
    desc "The domain name used by this switch."
    newvalues(:absent, /^((([a-z]|[0-9]|\-)+)\.)+([a-z])+$/i)
    defaultto :absent
  end

  newhostlistprop(:ntp_servers, :array_matching => :all) do
    desc "The NTP servers used by this switch.

    Valid format of ip addresses are:

    * IPV4, like 127.0.0.1
    * IPV6, like FE80::21A:2FFF:FE30:ECF0

    It is also possible to supply an array of values."
  end

  newhostlistprop(:logging_servers) do
    desc "The logging servers used by this switch."
  end

  newproperty(:clock_timezone) do
    desc "The local timezone of this switch."
    newvalues(/^\w+\s-?\d+(\s-?\d+)?$/)
  end

  newproperty(:system_mtu_routing) do
    desc "The MTU used by this Switch's IP Interfaces."
    newvalues(/^[0-9]+$/)
    defaultto 1500
    munge do |value|
      case super(value)
      when Integer, Fixnum, Bignum
        value
      when /^\d+$/
        Integer(value)
      else
        self.fail "Invalid System MTU routing Value: #{value.inspect}"
      end
    end
  end


  newproperty(:aaa_new_model) do
    desc "aaa new model"
    newvalues(:present, :absent)
    defaultto :present
  end
  newproperty(:ip_classless) do
    desc "Whether or not the Switch should follow Classless Routing
    forwarding Rules."

    newvalues(:present, :absent)
    defaultto :present
  end

  newproperty(:ip_domain_lookup) do
    desc "Enable IP DNS Queries for CLNS NSAP Addresses for this Switch."
    newvalues(:present, :absent)
  end

  newproperty(:ip_domain_lookup_source_interface) do
    desc "The Interface used by this Switch to do DNS lookups."
    newvalues(:absent, /^\S+$/)
    defaultto :absent
  end

  newhostlistprop(:ip_name_servers) do
    desc "The DNS Servers used by this Switch."
  end

  newipprop(:ip_default_gateway) do
    desc "The default Gateway used by IP Services on this Switch."

    defaultto :absent
  end

  newproperty(:ip_radius_source_interface) do
    desc "The Interface used by this Switch to do RADIUS."
    newvalues(:absent, /^\S+$/)
    defaultto :absent
  end

  newproperty(:logging_trap) do
    desc "Set the Syslog logging level for this Switch."
    newvalues(:emergencies, :alerts, :critical, :errors, :warnings,
              :notifications, :informational, :debugging)
    aliasvalue(0, :emergencies)
    aliasvalue(1, :alerts)
    aliasvalue(2, :critical)
    aliasvalue(3, :errors)
    aliasvalue(4, :warnings)
    aliasvalue(5, :notifications)
    aliasvalue(6, :informational)
    aliasvalue(7, :debugging)

    defaultto :critical
  end

  newproperty(:logging_facility) do
    desc "Set the Facility Parameter for Syslog Messages from this Switch."
    newvalues(:auth, :cron, :daemon, :kern, /^local[0-7]$/, :lpr, :mail,
              :news, /^sys(9|1[0-4])$/, :syslog, :user, :uucp)
    defaultto :syslog
  end

  newproperty(:vtp_version) do
    # TODO: Extract to a new Type
    desc "The VTP Version used in this Domain."
    newvalues(:absent, 1, 2, 3)
  end

  newproperty(:vtp_operation_mode) do
    # TODO: Extract to a new Type
    desc "The VTP device mode of this Switch."
    validate do |value|
      return true if value == :absent
      self.fail "Invalid VTP Operation Mode, must be a single String: #{value.inspect}" unless value.is_a?(String)
      self.fail "Invalid VTP Operation Mode: #{value.inspect}" unless value =~ /^(client|off|server|transparent)\s?(mst|unknown|vlan)?$/
    end
  end

  newproperty(:vtp_password) do
    # TODO: Extract to a new Type
    desc "The Password for this Domain."
    newvalues(:absent, /^\S+$/)
  end

  newproperty(:vtp_domain) do
    desc "The VTP Domain"
    newvalues(:absent, /^\S+$/)
  end

  newproperty(:enable_secret) do
    desc "The enable Secret for this Switch."
    newvalues(:absent, /^\S+$/)
  end

  newproperty(:ip_dhcp_snooping) do
    # TODO: Extract to a new Type
    newvalues(:present, :absent)
    defaultto :absent
  end

  newproperty(:ip_dhcp_snooping_vlans) do
    # TODO: Extract to a new Type
    newvalues(:absent, /^\d+-?(\d+)?/)
    defaultto :absent
  end

  newproperty(:ip_dhcp_snooping_remote_id) do
    # TODO: Extract to a new Type
    newvalues(:hostname, :absent, /^\S+$/)
  end

  newproperty(:ip_dhcp_relay_information) do
    # TODO: Extract to a new Type
    newvalues(:absent, /^.+$/)
    defaultto :absent
  end

  newproperty(:password_encryption) do
    newvalues(:present, :absent)
    defaultto :present
  end

  newproperty(:ip_ssh) do
    newvalues(:absent, :present)
  end

  newproperty(:ip_ssh_version) do
    newvalues(1, 2)
  end

  newproperty(:errdisable_recovery_cause, :array_matching => :all) do
    newvalues(:absent, 'arp-inspection', 'bpduguard', 'channel-misconfig',
              'community-limit', 'dhcp-rate-limit', 'dtp-flap',
              'gbic-invalid', 'inline-power', 'invalid-policy', 'l2ptguard',
              'link-flap', 'loopback', 'lsgroup', 'mac-limit', 'pagp-flap',
              'port-mode-failure', 'pppoe-ia-rate-limit', 'psecure-violation',
              'security-violation', 'sfp-config-mismatch', 'small-frame',
              'storm-control', 'udld', 'vmps')

    munge do |value|
      if value == :absent
        value
      else
        value.to_s
      end
    end

    def insync?(is)
      return ([is].flatten.sort == [@should].flatten.sort || [is].flatten.sort == [@should].flatten.map(&:to_s).sort)
    end
  end

  newproperty(:errdisable_recovery_interval) do
    newvalues(:absent, /^\d+$/)

    validate do |value|
      return if value == :absent
      self.fail "'errdisable recovery interval' must be between 30-86400" unless value.to_i <= 86400 && value.to_i >= 30
    end
  end

end
