require 'puppet/util/network_device/cisco_ios/model'
require 'puppet/util/network_device/cisco_ios/model/interface'

module Puppet::Util::NetworkDevice::Cisco_ios::Model::Interface::Base

  # TODO: Generalize me!
  def self.ifprop(base, param, base_command = param, &block)
    base.register_scoped param, /^(interface\s+(\S+).*?)^!/m do
      cmd 'sh run'
      match /^\s*#{base_command}\s+(.*?)\s*$/
      after :description
      add do |transport, value|
        transport.command("#{base_command} #{value}")
      end
      remove do |transport, old_value|
        transport.command("no #{base_command} #{old_value}")
      end
      # Pass the Block to a Helper Method so we are in the right Scope
      # when evaluating the block
      evaluate(&block) if block
    end
  end

  def self.register(base)
    ifprop(base, :description)
    ifprop(base, :mode, "switchport mode")
    ifprop(base, :access, "switchport access vlan") do
      after :mode
    end
    ifprop(base, :trunk_allowed_vlan, "switchport trunk allowed vlan") do
      after :mode
    end
    ifprop(base, :trunk_encapsulation, "switchport trunk encapsulation") do
      before :mode
    end
    ifprop(base, :trunk_native_vlan, "switchport trunk native vlan") do
      after :mode
    end
    ifprop(base, :negotiate) do
      match do |txt|
        !!(txt.match(/^\s*switchport nonegotiate\s*$/)) ? :false : :true # http://projects.puppetlabs.com/issues/17519
      end
      after :mode
      add do |transport, value|
        if value == :false
          transport.command("switchport nonegotiate")
        else
          transport.command("no switchport nonegotiate")
        end
      end
      # This is just a dummy
      remove {|*_| }
    end

    ifprop(base, :port_security, "switchport port-security") do
      match do |txt|
        port_sec = txt.match(/^\s*switchport port-security\s*$/)
        violation = txt.scan(/^\s*switchport port-security violation\s+(.*?)\s*$/).flatten.first
        if port_sec and violation
          violation
          # this is here so we can make sure that leftovers are removed
        elsif !port_sec and violation
          violation
        end
      end
      after :mode
      add do |transport, value|
        transport.command("switchport port-security")
        transport.command("switchport port-security violation #{value}")
      end
      remove do |transport, old_value|
        transport.command("no switchport port-security")
        transport.command("no switchport port-security violation #{old_value}")
      end
    end

    ifprop(base, :port_security_mac_address, "switchport port-security mac-address") do
      after :port_security
    end
    ifprop(base, :port_security_aging_time, "switchport port-security aging time") do
      after :port_security
    end
    ifprop(base, :port_security_aging_type, "switchport port-security aging type") do
      after :port_security
    end

    ifprop(base, :spanning_tree) do
      match do |txt|
        txt.match(/^\s*spanning-tree portfast\s*$/) ? :leaf : :node
      end
      after :mode
      add do |transport, value|
        if value == :leaf
          transport.command("spanning-tree portfast")
        end
      end
      remove do |transport, old_value|
        if old_value == :leaf
          transport.command("spanning-tree portfast disable")
        end
      end
    end

    ifprop(base, :spanning_tree_bpduguard) do
      match do |txt|
        txt.match(/^\s*spanning-tree bpduguard enable\s*$/) ? :present : :absent
      end
      after :spanning_tree
      add do |transport, _|
        transport.command("spanning-tree bpduguard enable")
      end
      remove do |transport, _|
        transport.command("spanning-tree bpduguard disable")
      end
    end

    ifprop(base, :spanning_tree_guard, "spanning-tree guard") do
      after :spanning_tree
    end
    ifprop(base, :spanning_tree_cost, "spanning-tree cost") do
      after :spanning_tree
    end
    ifprop(base, :spanning_tree_port_priority, "spanning-tree port-priority") do
      after :spanning_tree
    end
    ifprop(base, :dhcp_snooping_limit_rate, "ip dhcp snooping limit rate")
    ifprop(base, :dhcp_snooping_trust) do
      match do |txt|
        txt.match(/^\s*ip dhcp snooping trust\s*$/) ? :present : :absent
      end
      add do |transport, _|
        transport.command("ip dhcp snooping trust")
      end
      remove do |transport, _|
        transport.command("no ip dhcp snooping trust")
      end
    end

    ifprop(base, :ip_vrf_forwarding, "ip vrf forwarding") do
      add do |transport, value|
        transport.command("ip vrf forwarding #{value}", { :prompt => /(% Interface .* IP address .* removed due to (en|dis)abling VRF .*\n)?[^%]*\(config-if\)#/ })
      end
      remove do |transport, old_value|
        transport.command("no ip vrf forwarding #{old_value}", { :prompt => /(% Interface .* IP address .* removed due to (en|dis)abling VRF .*\n)?[^%]*\(config-if\)#/ })
      end
    end

    ifprop(base, :ip_address, "ip address") do
      after :ip_vrf_forwarding
    end

    ifprop(base, :standby_delay_reload, "standby delay reload")

    if base.facts && base.facts['canonicalized_hardwaremodel'] == 'c6509'
      base.register_new_module('c6509', 'hardware')
    end

    if base.facts && base.facts['canonicalized_hardwaremodel'] == 'c4500'
      base.register_new_module('c4500', 'hardware')
    end

    if base.facts && base.facts['canonicalized_hardwaremodel'] == 'c2960'
      base.register_new_module('c2960', 'hardware')
    end
  end
end

