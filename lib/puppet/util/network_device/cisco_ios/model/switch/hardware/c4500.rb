require 'puppet/util/network_device/cisco_ios/model/switch/hardware'

module Puppet::Util::NetworkDevice::Cisco_ios::Model::Switch::Hardware::C4500

  def self.register(base)
    base.register_param :system_mtu_routing do
      match /^Global Ethernet MTU is (\d+)/
      cmd 'sh system mtu'
      add do |transport, value|
        transport.command("system mtu #{value}")
      end
      remove do |transport, old_value|
        transport.command("no system mtu #{old_value}")
      end
    end

    base.register_param :ip_classless do
      match do |_|
        :present
      end
      cmd 'sh run'
      add { |*_| }
      remove { |*_|}
    end

    base.register_param :logging_servers do
      match do |txt|
        txt.scan(/^logging\s+host\s+(\S+)$/).flatten
      end
      cmd 'sh run'
      add do |transport, value|
        transport.command("logging #{value}")
      end
      remove do |transport, old_value|
        transport.command("no logging #{old_value}")
      end
    end
  end
end
