require 'puppet/util/network_device/cisco_ios/model/switch/hardware'

module Puppet::Util::NetworkDevice::Cisco_ios::Model::Switch::Hardware::C4500

  def self.register(base)
    base.register_simple(:system_mtu_routing, /^Global Ethernet MTU is (\d+)/, 'sh system mtu', 'system mtu')

    base.register_param :ip_classless do
      match do |_|
        :present
      end
      cmd 'sh run'
      add { |*_| }
      remove { |*_|}
    end

    base.register_array(:logging_servers, /^logging\s+host\s+(\S+)$/, 'sh run', 'logging')
  end
end
