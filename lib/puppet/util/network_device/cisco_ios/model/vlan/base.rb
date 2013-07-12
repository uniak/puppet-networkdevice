require 'puppet/util/network_device/cisco_ios/model'
require 'puppet/util/network_device/cisco_ios/model/vlan'

module Puppet::Util::NetworkDevice::Cisco_ios::Model::Vlan::Base

  def self.register(base)
    vlan_scope = /^((\d+)\s+(.*))/
    base.register_scoped :ensure, vlan_scope do
      match do |txt|
        unless txt.nil?
          txt.match(/\S+/) ? :present : :absent
        else
          :absent
        end
      end
      cmd 'sh vlan brief'
      default :absent
      add { |*_| }
      remove { |*_| }
    end
    base.register_scoped :desc, vlan_scope do
      match /^\d+\s(\S+)/
      cmd 'sh vlan brief'
      add do |transport, value|
        transport.command("name #{value}")
      end
      remove { |*_| }
    end
  end
end
