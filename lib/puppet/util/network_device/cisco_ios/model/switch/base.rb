require 'puppet/util/network_device/cisco_ios/model'
require 'puppet/util/network_device/cisco_ios/model/aaa_group'
require 'puppet/util/network_device/cisco_ios/model/acl'
require 'puppet/util/network_device/cisco_ios/model/hsrp_standby_group'
require 'puppet/util/network_device/cisco_ios/model/interface'
require 'puppet/util/network_device/cisco_ios/model/line'
require 'puppet/util/network_device/cisco_ios/model/model_value'
require 'puppet/util/network_device/cisco_ios/model/snmp'
require 'puppet/util/network_device/cisco_ios/model/snmp_community'
require 'puppet/util/network_device/cisco_ios/model/snmp_host'
require 'puppet/util/network_device/cisco_ios/model/switch'
require 'puppet/util/network_device/cisco_ios/model/vlan'
require 'puppet/util/network_device/cisco_ios/model/vrf'

module Puppet::Util::NetworkDevice::Cisco_ios::Model::Switch::Base

  def self.register(base)
    base.register_simple(:hostname, /^hostname\s+(\S+)$/, 'sh run', 'hostname')

    base.register_simple(:ip_domain_name, /^ip\s+domain-name\s+(\S+)$/, 'sh run', 'ip domain-name')

    base.register_array(:ntp_servers, /^ntp\s+server\s+(\S+)$/, 'sh run', 'ntp server') do |values|
      values.select { |ip| IPAddr.new(ip) }
    end

    base.register_array(:logging_servers, /^logging\s+(\S+)$/, 'sh run', 'logging')

    # MET 1 0 vs. MET 1
    # in conf t vs sh run
    base.register_simple(:clock_timezone, /^clock\s+timezone\s+(.+)$/, 'sh run', 'clock timezone')

    base.register_simple(:system_mtu_routing, /^system\s+mtu\s+routing\s+(\d+)$/, 'sh run', 'system mtu routing')

    base.register_bool(:ip_classless, /^ip\s+classless$/, 'sh run', 'ip classless')

    base.register_bool(:ip_domain_lookup, /^ip\s+domain-lookup$/, 'sh run', 'ip domain-lookup')

    base.register_simple(:ip_domain_lookup_source_interface, /^ip\s+domain-lookup\s+source-interface\s+(\S+)$/, 'sh run', 'ip domain-lookup source-interface')

    base.register_array(:ip_name_servers, /^ip\s+name-server\s+(\S+)$/, 'sh run', 'ip name-server') do |values|
      values.select { |ip| IPAddr.new(ip) }
    end

    base.register_simple(:ip_radius_source_interface, /^ip\s+radius\s+source-interface\s+(\S+)\s?$/, 'sh run', 'ip radius source-interface')
    base.register_simple(:logging_trap, /^logging\s+trap\s+(\S+)$/, 'sh run', 'logging trap')
    base.register_simple(:logging_facility, /^logging\s+facility\s+(\S+)$/, 'sh run', 'logging facility')

    base.register_param :ip_default_gateway do
      match do |txt|
        txt.match(/^ip\s+default-gateway\s+(\S+)$/)
        if $1
          IPAddr.new($1)
        else
          :absent
        end
      end
      cmd 'sh run'
      add do |transport, value|
        transport.command("ip default-gateway #{value}")
      end
      remove do |transport, old_value|
        transport.command("no ip default-gateway #{old_value}")
      end
    end

    # TODO: Separate Type for vtp properties?
    base.register_simple(:vtp_version, /^VTP\sversion\srunning\s+:\s+(\d)$/, 'sh vtp status', 'vtp version')

    base.register_param :vtp_domain do
      match /^VTP\sDomain\sName\s+:\s+(\S+)$/
      cmd 'sh vtp status'
      add do |transport, value|
        transport.command("vtp domain #{value}")
      end
      remove do |transport, _|
        # TODO: Find out the real NULL Value ...
        transport.command("vtp domain NULL")
      end
    end

    base.register_param :vtp_operation_mode do
      match do |txt|
        txt.scan(/^VTP\sOperating\sMode\s+:\s+(?:.*\s)?(\S+)$/).flatten[0].downcase
      end
      cmd 'sh vtp status'
      add do |transport, value|
        transport.command("vtp mode #{value}")
      end
      remove do |transport, old_value|
        transport.command("no vtp mode #{old_value}")
      end
    end

    base.register_simple(:vtp_password, /^VTP\sPassword:\s+(\S+)$/, 'sh vtp password', 'vtp password')

    # TODO: Separate Type for dhcp properties?
    base.register_bool(:ip_dhcp_snooping, /^ip\sdhcp\ssnooping$/, 'sh run', 'ip dhcp snooping')

    base.register_simple(:ip_dhcp_snooping_vlans, /^ip\sdhcp\ssnooping\svlan\s(\S+)$/, 'sh run', 'ip dhcp snooping vlan')

    base.register_param :ip_dhcp_snooping_remote_id do
      match(lambda do |txt|
        return :hostname if txt.match(/^ip\sdhcp\ssnooping\sinformation\soption\sformat\sremote-id\shostname$/)
        return $1 if txt.match(/^ip\sdhcp\ssnooping\sinformation\soption\sformat\sremote-id\s(\S+)$/)
        return :absent
      end)
      cmd 'sh run'
      add do |transport, value|
        transport.command("ip dhcp snooping information option format remote-id #{value}")
      end
      remove do |transport, old_value|
          transport.command("no ip dhcp snooping information option format remote-id #{old_value}") unless old_value.to_sym == :absent
      end
    end

    base.register_simple(:ip_dhcp_relay_information, /^ip\sdhcp\srelay\sinformation\s(.+)$/, 'sh run', 'ip dhcp relay information')

    base.register_bool(:password_encryption, /^service\s+password-encryption$/, 'sh run', 'service password-encryption')

    base.register_bool(:aaa_new_model, /^aaa\s+new-model$$/, 'sh run', 'aaa new-model')

    # TODO: Hardcode *sigh*
    base.register_param :ip_ssh do
      match do |txt|
        if txt.match(/^SSH Disabled/)
          :absent
        else
          :present
        end
      end
      cmd 'sh ip ssh'
      add do |transport, _|
        transport.command("crypto key generate rsa modulus 2048")
      end
      remove do |transport, _|
        transport.command("crypto key zeroize rsa")
      end
      after :ip_domain_name
    end

    base.register_param :ip_ssh_version do
      match /^ip ssh version (\d)$/
      cmd 'sh run'
      add do |transport, value|
        transport.command("ip ssh version #{value}")
      end
      remove do |transport, old_value|
        transport.command("no ip ssh version #{old_value}")
      end
      after :ip_ssh
    end

    base.register_param :errdisable_recovery_cause do
      match do |txt|
        cause = txt.scan(/^errdisable recovery cause (.*)$/).flatten
        cause.empty? ? nil : cause
      end
      cmd 'sh run'
      add do |transport, value|
        transport.command("errdisable recovery cause #{value}")
      end
      remove do |transport, old_value|
        transport.command("no errdisable recovery cause #{old_value}")
      end
    end

    base.register_simple(:errdisable_recovery_interval, /^errdisable recovery interval (\d+)\s*$/, 'sh run', 'errdisable recovery interval')

    base.register_model(:interfaces, Puppet::Util::NetworkDevice::Cisco_ios::Model::Interface, /^interface\s+(\S+)\r*$/, 'sh run')

    base.register_param(:hsrp_standby_groups, Puppet::Util::NetworkDevice::Cisco_ios::Model::ModelValue) do
      model Puppet::Util::NetworkDevice::Cisco_ios::Model::HsrpStandbyGroup
      cmd 'sh run'
      match do |txt|
        txt.scan(/^interface\s+(\S+)(.*?)^!/m).collect do |parent_interface,body|
          body.scan(/^\s*standby\s+(\d+)\s*/m).collect do |standby_group|
            new_model(:name => "#{parent_interface}/#{standby_group}", :parent_interface => parent_interface, :standby_group => standby_group) 
          end
        end.flatten
      end
    end

    base.register_model(:aaa_group, Puppet::Util::NetworkDevice::Cisco_ios::Model::Aaa_group, /^aaa group server (?:radius|tacacs\+)\s+(\S+)$/, 'sh run')

    base.register_model(:acl, Puppet::Util::NetworkDevice::Cisco_ios::Model::Acl, /^ip access-list (?:standard|extended)\s+(\S+)$/, 'sh run')

    base.register_model(:radius_server, Puppet::Util::NetworkDevice::Cisco_ios::Model::Radius_server, /^radius-server\s+host\s+(\S+)/, 'sh run')

    base.register_model(:user, Puppet::Util::NetworkDevice::Cisco_ios::Model::User, /^username\s+(\S+)/, 'sh run')

    base.register_param :lines, Puppet::Util::NetworkDevice::Cisco_ios::Model::ModelValue do
      model Puppet::Util::NetworkDevice::Cisco_ios::Model::Line
      match do |txt|
        txt.scan(/^line\s+((?:vty|con)\s+\d+(?:\s+\d+)?)$/).flatten.collect do |m|
          matches = m.match /(con|vty)\s+(\d+)(?:\s+(\d+))?/
          return unless matches
          type = matches[1]
          from = matches[2].to_i
          if matches[3].nil?
            # single number
            model.new(@transport, @facts, { :name => "#{type} #{from}" } )
          else
            # range
            to = matches[3].to_i
            (from..to).collect do |vty|
              model.new(@transport, @facts, { :name => "#{type} #{vty}" } )
            end
          end
        end.flatten
      end
      cmd 'sh run'
    end

    base.register_model(:snmp_community, Puppet::Util::NetworkDevice::Cisco_ios::Model::Snmp_community, /^snmp-server\scommunity\s+(\S+)/, 'sh run')

    base.register_model(:snmp_host, Puppet::Util::NetworkDevice::Cisco_ios::Model::Snmp_host, /^snmp-server\shost\s+(\S+)/, 'sh run')

    base.register_model(:vlan, Puppet::Util::NetworkDevice::Cisco_ios::Model::Vlan, /^(\d+)\s\S+/, 'sh vlan brief')

    base.register_model(:vrf, Puppet::Util::NetworkDevice::Cisco_ios::Model::Vrf, /^ip vrf (\w+)/, 'sh run')

    if base.facts && base.facts['canonicalized_hardwaremodel'] == 'c4500'
      base.register_new_module('c4500', 'hardware')
    end

    if base.facts && base.facts['canonicalized_hardwaremodel'] == 'c2960'
      base.register_new_module('c2960', 'hardware')
    end

  end
end
