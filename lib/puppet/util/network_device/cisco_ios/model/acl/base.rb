require 'puppet/util/network_device/cisco_ios/model'
require 'puppet/util/network_device/cisco_ios/model/interface'

module Puppet::Util::NetworkDevice::Cisco_ios::Model::Acl::Base
  def self.register(base)
    base.register_scoped :ensure, /^(ip\s+access-list\s+(?:standard|extended)\s+(\S+).*?\s*\n(?:\s[^\n]*\n)*)/ do
      cmd 'sh run'
      match do |txt|
        txt.match(/\S+/) ? :present : :absent
      end
      default :absent
    end

    base.register_scoped :type, /^(ip\s+access-list\s+(?:standard|extended)\s+(\S+).*?\s*\n(?:\s[^\n]*\n)*)/ do
      cmd 'sh run'
      match /^ip\s+access-list\s+(standard|extended)/
      add { |*_| }
      remove { |*_| }
    end

    base.register_scoped :acl, /^(ip\s+access-list\s+(?:standard|extended)\s+(\S+).*?\s*\n(?:\s[^\n]*\n)*)/ do
      cmd 'sh run'
      match do |txt|
        txt.split(/\n/).drop(1).collect {|l| l.strip }
      end
      add do |transport, value|
        transport.command(value)
      end
      remove do |transport, old_value|
        transport.command("no #{old_value}")
      end
    end
  end
end

