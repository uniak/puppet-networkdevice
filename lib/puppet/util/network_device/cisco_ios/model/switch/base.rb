require 'puppet/util/network_device/cisco_ios/model'
require 'puppet/util/network_device/cisco_ios/model/aaa_group'
require 'puppet/util/network_device/cisco_ios/model/acl'
require 'puppet/util/network_device/cisco_ios/model/snmp'
require 'puppet/util/network_device/cisco_ios/model/snmp_community'
require 'puppet/util/network_device/cisco_ios/model/snmp_host'
require 'puppet/util/network_device/cisco_ios/model/interface'
require 'puppet/util/network_device/cisco_ios/model/line'
require 'puppet/util/network_device/cisco_ios/model/model_value'
require 'puppet/util/network_device/cisco_ios/model/switch'

module Puppet::Util::NetworkDevice::Cisco_ios::Model::Switch::Base
  # register a simple param using the specified regexp and commands
  def self.register_simple(base, param, match_re, fetch_cmd, cmd)
    base.register_param param do
      match match_re
      cmd fetch_cmd
      add  do |transport, value|
        transport.command("#{cmd} #{value}")
      end
      remove do |transport, old_value|
        transport.command("no #{cmd} #{old_value}")
      end
    end
  end

  # register a model based param
  def self.register_model(base, param, klass, match_re, fetch_cmd)
    base.register_param param, Puppet::Util::NetworkDevice::Cisco_ios::Model::ModelValue do
      model klass
      match match_re
      cmd fetch_cmd
    end
  end

  # register a simple yes/no param. the regexp must match if the param is present
  def self.register_bool(base, param, match_re, fetch_cmd, cmd)
    base.register_param param do
      match do |txt|
        txt.match(match_re)
        if $1 == 'no'
          :absent
        else
          :present
        end
      end
      cmd fetch_cmd
      add do |transport, _|
        transport.command(cmd)
      end
      remove do |transport, _|
        transport.command("no #{cmd}")
      end
    end
  end

  def self.register(base)
    self.register_simple(base, :hostname, /^hostname\s+(\S+)$/, 'sh run', 'hostname')

    self.register_simple(base, :ip_domain_name, /^ip\s+domain-name\s+(\S+)$/, 'sh run', 'ip domain-name')

    base.register_param :ntp_servers do
      match do |txt|
        txt.scan(/^ntp\s+server\s+(\S+)$/).flatten.map do |ip|
          IPAddr.new(ip)
        end
      end
      cmd 'sh run'
      add do |transport, value|
        transport.command("ntp server #{value}")
      end
      remove do |transport, old_value|
        transport.command("no ntp server #{old_value}")
      end
    end

    base.register_param :logging_servers do
      match do |txt|
        txt.scan(/^logging\s+(\S+)$/).flatten
      end
      cmd 'sh run'
      add do |transport, value|
        transport.command("logging #{value}")
      end
      remove do |transport, old_value|
        transport.command("no logging #{old_value}")
      end
    end

    # MET 1 0 vs. MET 1
    # in conf t vs sh run
    self.register_simple(base, :clock_timezone, /^clock\s+timezone\s+(.+)$/, 'sh run', 'clock timezone')

    self.register_simple(base, :system_mtu_routing, /^system\s+mtu\s+routing\s+(\d+)$/, 'sh run', 'system mtu routing')

    self.register_bool(base, :ip_classless, /^ip\s+classless$/, 'sh run', 'ip classless')

    self.register_bool(base, :ip_domain_lookup, /^ip\s+domain-lookup$/, 'sh run', 'ip domain-lookup')

    self.register_simple(base, :ip_domain_lookup_source_interface, /^ip\s+domain-lookup\s+source-interface\s+(\S+)$/, 'sh run', 'ip domain-lookup source-interface')

    base.register_param :ip_name_servers do
      match do |txt|
        txt.scan(/^ip\s+name-server\s+(\S+)$/).flatten.map do |ip|
          IPAddr.new(ip)
        end
      end
      cmd 'sh run'
      add do |transport, value|
        transport.command("ip name-server #{value}")
      end
      remove do |transport, old_value|
        transport.command("no ip name-server #{old_value}")
      end
    end

    self.register_simple(base, :ip_radius_source_interface, /^ip\s+radius\s+source-interface\s+(\S+)\s?$/, 'sh run', 'ip radius source-interface')
    self.register_simple(base, :logging_trap, /^logging\s+trap\s+(\S+)$/, 'sh run', 'logging trap')
    self.register_simple(base, :logging_facility, /^logging\s+facility\s+(\S+)$/, 'sh run', 'logging facility')

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
    self.register_simple(base, :vtp_version, /^VTP\sversion\srunning\s+:\s+(\d)$/, 'sh vtp status', 'vtp version')

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

    self.register_simple(base, :vtp_password, /^VTP\sPassword:\s+(\S+)$/, 'sh vtp password', 'vtp password')

    # TODO: Separate Type for dhcp properties?
    base.register_param :ip_dhcp_snooping do
      match do |txt|
        if txt.match(/^ip\sdhcp\ssnooping$/)
          :present
        else
          :absent
        end
      end
      cmd 'sh run'
      add do |transport, _|
        transport.command("ip dhcp snooping")
      end
      remove do |transport, _|
        transport.command("no ip dhcp snooping")
      end
    end

    self.register_simple(base, :ip_dhcp_snooping_vlans, /^ip\sdhcp\ssnooping\svlan\s(\S+)$/, 'sh run', 'ip dhcp snooping vlan')

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

    self.register_simple(base, :ip_dhcp_relay_information, /^ip\sdhcp\srelay\sinformation\s(.+)$/, 'sh run', 'ip dhcp relay information')

    self.register_bool(base, :password_encryption, /^service\s+password-encryption$/, 'sh run', 'service password-encryption')

    self.register_bool(base, :aaa_new_model, /^aaa\s+new-model$$/, 'sh run', 'aaa new-model')

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

    self.register_simple(base, :errdisable_recovery_interval, /^errdisable recovery interval (\d+)\s*$/, 'sh run', 'errdisable recovery interval')

    self.register_model(base, :interfaces, Puppet::Util::NetworkDevice::Cisco_ios::Model::Interface, /^interface\s+(\S+)$/, 'sh run')

    self.register_model(base, :aaa_groups, Puppet::Util::NetworkDevice::Cisco_ios::Model::Aaa_group, /^aaa group server (?:radius|tacacs\+)\s+(\S+)$/, 'sh run')

    self.register_model(base, :acl, Puppet::Util::NetworkDevice::Cisco_ios::Model::Acl, /^ip access-list (?:standard|extended)\s+(\S+)$/, 'sh run')

    self.register_model(base, :radius_server, Puppet::Util::NetworkDevice::Cisco_ios::Model::Radius_server, /^radius-server\s+host\s+(\S+)/, 'sh run')

    self.register_model(base, :user, Puppet::Util::NetworkDevice::Cisco_ios::Model::User, /^username\s+(\S+)/, 'sh run')

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

    self.register_model(base, :snmp_communities, Puppet::Util::NetworkDevice::Cisco_ios::Model::Snmp_community, /^snmp-server\scommunity\s+(\S+)/, 'sh run')

    self.register_model(base, :snmp_hosts, Puppet::Util::NetworkDevice::Cisco_ios::Model::Snmp_host, /^snmp-server\shost\s+(\S+)/, 'sh run')

    self.register_model(base, :vlan, Puppet::Util::NetworkDevice::Cisco_ios::Model::Vlan, /^(\d+)\s\S+/, 'sh vlan brief')

    if base.facts && base.facts['canonicalized_hardwaremodel'] == 'c4500'
      base.register_new_module('c4500', 'hardware')
    end

    if base.facts && base.facts['canonicalized_hardwaremodel'] == 'c2960'
      base.register_new_module('c2960', 'hardware')
    end

  end
end
