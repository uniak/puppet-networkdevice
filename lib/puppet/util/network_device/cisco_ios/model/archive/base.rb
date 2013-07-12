require 'puppet/util/network_device/cisco_ios/model'
require 'puppet/util/network_device/cisco_ios/model/archive'

module Puppet::Util::NetworkDevice::Cisco_ios::Model::Archive::Base
  def self.archive_prop(base, param, base_command = param, &block)
    archive_scope = /^((archive)\n(?:\s[^\n]*\n)*)/
    base.register_scoped param, archive_scope do
      cmd 'sh run'
      match /^\s*#{base_command}\s+(.*)$/
      scope_match do |scope, _|
        [[scope, :running]]
      end
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
    archive_prop(base, :path)
    archive_prop(base, :write_memory) do
      match do |txt|
        txt.match(/write-memory/) ? :present : :absent
      end
      add do |transport, _|
        transport.command('write-memory')
      end
      remove do |transport, _|
        transport.command('no write-memory')
      end
    end
    archive_prop(base, :time_period, 'time-period')
  end
end
