require 'puppet/util/network_device/cisco_ios/model'
require 'puppet/util/network_device/cisco_ios/model/snmp_host'

module Puppet::Util::NetworkDevice::Cisco_ios::Model::SnmpHost::Base
  def self.register(base)
    base.base_cmd = "snmp-server host <%= name %>"
    snmp_scope = /^(snmp-server host (\S+)(.*))/
    base.register_scoped :ensure, snmp_scope do
      match do |txt|
        unless txt.nil?
          txt.match(/\S+/) ? :present : :absent
        else
          :absent
        end
      end
      cmd 'sh run'
      default :absent
    end
    base.register_scoped :community, snmp_scope do
      match /^snmp-server host \S+\s+(\S+)/
      cmd 'sh run'
      supported true
      fragment "<%= value %>"
    end
    base.register_scoped :udp_port, snmp_scope do
      match /udp-port (\d+)/
      cmd 'sh run'
      supported true
      fragment "udp-port <%= value %>"
      after :community
    end
  end
end
