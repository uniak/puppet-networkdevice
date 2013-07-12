require 'puppet/util/network_device/cisco_ios/model'
require 'puppet/util/network_device/cisco_ios/model/interface'

module Puppet::Util::NetworkDevice::Cisco_ios::Model::Line::Base

  def self.lineprop(base, param, base_command = param, &block)
    base.register_scoped param, /^(line\s+((?:con|vty)\s+\d+(?:\s+\d+)?)\s*\n(?:\s[^\n]*\n)*)/ do
      cmd 'sh run'
      match /^\s*#{base_command}\s+(.*)$/
      scope_match do |scope, scope_name|
        matches = scope_name.match /(con|vty)\s+(\d+)(?:\s+(\d+))?/
        return unless matches
        type = matches[1]
        from = matches[2].to_i
        if matches[3].nil?
          # single number
          [ [scope, "#{type} #{from}"] ]
        else
          # range
          to = matches[3].to_i
          (from..to).collect { |vty| [scope, "#{type} #{vty}"] }
        end
      end
      add do |transport, value|
        transport.command("#{base_command} #{value}")
      end
      remove do |transport, old_value|
        transport.command("no #{base_command} #{old_value}")
      end
      # Pass the Block to a Helper Method so we are in the right
      # Scope when evaluating the block
      evaluate(&block) if block
    end
  end

  def self.register(base)
    lineprop(base, :access_class, 'access-class') do
      match /^\s*access-class\s+(.*)$/
    end

    lineprop(base, :logging) do
      match /^\s*logging\s+(.*)$/
    end

    lineprop(base, :exec_timeout) do
      match do |txt|
        matches = /^\s*exec-timeout\s+(\d+)\s+(\d+).*$/.match txt
        if matches
          matches[1].to_i * 60 + matches[2].to_i
        else
          600 # ios doesn't show the config if it has this value
        end
      end

      add do |transport,value|
        secs = value.to_i % 60
        mins = (value.to_i - secs) / 60
        transport.command("exec-timeout #{mins} #{secs}")
      end
      remove do |transport,old_value|
        transport.command("no exec-timeout")
      end
    end

    lineprop(base, :transport, 'transport input') do
      match /^\s*transport\s+input\s+(all|none|ssh|telnet)$/
      remove { |*_| }
    end
  end
end

