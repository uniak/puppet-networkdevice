require 'puppet/util/network_device/cisco_ios/model/switch/hardware'

module Puppet::Util::NetworkDevice::Cisco_ios::Model::Switch::Hardware::C2960

  def self.register(base)
    base.register_param :ip_classless do
      match do |_|
        :present
      end
      cmd 'sh run'
      add { |*_| }
      remove { |*_|}
    end
  end
end
