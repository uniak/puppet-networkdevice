require 'puppet/util/network_device/cisco_ios/model/interface/hardware'

module Puppet::Util::NetworkDevice::Cisco_ios::Model::Interface::Hardware::C6509

  # TODO: Generalize me!
  def self.ifprop(base, param, base_command = param, &block)
    base.register_scoped param, /^(interface\s+(\S+).*?)^!/m do
      cmd 'sh run'
      match /^\s*#{base_command}\s+(.*)$/
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
    ifprop(base, :trunk_encapsulation) do
      cmd 'sh run'
      match do |txt|
        txt.match(/^\s*switchport mode trunk\s*$/) ? :dot1q : nil
      end
      add do |transport, value|
        transport.command("switchport")
        transport.command("switchport trunk encapsulation dot1q")
      end      
      remove { |*_| }
      before :mode
    end
  end
end
