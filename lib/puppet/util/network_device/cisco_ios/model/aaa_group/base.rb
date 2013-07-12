require 'puppet/util/network_device/cisco_ios/model'
require 'puppet/util/network_device/cisco_ios/model/interface'

module Puppet::Util::NetworkDevice::Cisco_ios::Model::Aaa_group::Base

  def self.aaaprop(base, param, base_command = param, &block)
    base.register_scoped param, /^(aaa\s+group\s+server\s+(?:radius|tacacs\+)\s+(\S+).*?)^!/m do
      cmd 'sh run'
      match /^\s*#{base_command}\s+(.*)$/
      supported true
      # Pass the Block to a Helper Method so we are in the right
      # Scope when evaluating the block
      evaluate(&block) if block
    end
  end

  def self.register(base)
    base.register_scoped :ensure, /^(aaa\s+group\s+server\s+(?:radius|tacacs\+)\s+(\S+)).*?^!/m do
      cmd 'sh run'
      match do |txt|
        txt.match(/\S+/) ? :present : :absent
      end
      default :absent
      supported true
    end

    base.register_scoped :protocol, /^(aaa\s+group\s+server\s+(?:radius|tacacs\+)\s+(\S+)).*?^!/m do
      cmd 'sh run'
      match /^aaa\s+group\s+server\s+(radius|tacacs\+)\s/
      supported true
    end

    aaaprop(base, :acct_port) do
      match /^\s*server\s+.*acct-port\s+(\d+).*$/
      fragment "acct-port <%= value %>"
      after :auth_port
    end

    aaaprop(base, :auth_port) do
      match /^\s*server\s+.*auth-port\s+(\d+).*$/
      fragment "auth-port <%= value %>"
      after :server
    end

    aaaprop(base, :server) do
      match /^\s*server\s+([^ ]*).*$/
      fragment "server <%= value %>"
    end

    base.register_scoped :local_authentication, /^(aaa\s+authentication\s+login\s+default\s+group\s+(\S+)\s+local)/, Puppet::Util::NetworkDevice::Cisco_ios::Model::ScopedValue do
      cmd 'sh run'
      match do |txt|
        (!txt.nil? and txt.length > 0) ? :true : :false
      end
      add do |transport,value|
        transport.command("aaa authentication login default group #{@scope_name} local")
      end
      # Danger here: can only delete *ALL* authorization groups
      #remove do |transport,value|
      #  transport.command("no aaa authorization exec default")
      #end
      remove { |*_| }
    end

    base.register_scoped :local_authorization, /^(aaa\s+authorization\s+exec\s+default\s+group\s+(\S+)\s+local)/, Puppet::Util::NetworkDevice::Cisco_ios::Model::ScopedValue do
      cmd 'sh run'
      match do |txt|
        (!txt.nil? and txt.length > 0) ? :true : :false
      end
      add do |transport,value|
        transport.command("aaa authorization exec default group #{@scope_name} local")
      end
      # Danger here: can only delete *ALL* authorization groups
      #remove do |transport,value|
      #  transport.command("no aaa authorization exec default")
      #end
      remove { |*_| }
    end
  end
end

