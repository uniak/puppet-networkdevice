require 'puppet/util/network_device/cisco_ios/model'
require 'puppet/util/network_device/cisco_ios/model/hsrp_standby_group'

module Puppet::Util::NetworkDevice::Cisco_ios::Model::HsrpStandbyGroup::Base

  # TODO: Generalize me!
  def self.hsgprop(base, param, base_command = param, &block)
    base.register_scoped param, /^(interface\s+(\S+).*?)^!/m do
      cmd 'sh run'
      match /^\s*standby #{base.standby_group} #{base_command}\s+(.*?)\s*$/
      scope_match do |scope, scope_name|
        # puts "scope_name=#{scope_name}; scope=#{scope.inspect}"
        result = Hash.new { |hash,key| hash[key] = [] }
        
        scope.split("\n").collect do |l|
          matches = l.match /^\s*standby\s+(\d+)\s+(.*)$/
          next if matches.nil?
          next unless matches.length > 1
          group = matches[1]
          result["#{scope_name}/#{group}"] << l
        end
        result.keys.collect  { |k| [result[k].join("\n"),k ] }
      end
      add do |transport, value|
        transport.command("standby #{base.standby_group} #{base_command} #{value}")
      end
      remove do |transport, old_value|
        transport.command("no standby #{base.standby_group} #{base_command} #{old_value}")
      end
      # Pass the Block to a Helper Method so we are in the right Scope
      # when evaluating the block
      evaluate(&block) if block
    end
  end

  def self.register(base)
    hsgprop(base, :ip)
    hsgprop(base, :timers)
    hsgprop(base, :authentication)
    hsgprop(base, :priority)
    hsgprop(base, :preempt) do
      match do |txt|
        txt.match(/^\s*standby\s+\d+\s+preempt$/) ? :present : :absent
      end
      add do |transport, value|
        transport.command("standby #{base.standby_group} preempt")
      end
      remove do |transport, old_value|
        transport.command("no standby #{base.standby_group} preempt")
      end
    end
    hsgprop(base, :preempt_delay_minimum, "preempt delay minimum")
    hsgprop(base, :preempt_delay_reload, "preempt delay reload")
    hsgprop(base, :preempt_delay_sync, "preempt delay sync")

    # TODO: hsgprop(base, :track)

    # if base.facts && base.facts['canonicalized_hardwaremodel'] == 'c6509'
    #   base.register_new_module('c6509', 'hardware')
    # end

    # if base.facts && base.facts['canonicalized_hardwaremodel'] == 'c4500'
    #   base.register_new_module('c4500', 'hardware')
    # end

    # if base.facts && base.facts['canonicalized_hardwaremodel'] == 'c2960'
    #   base.register_new_module('c2960', 'hardware')
    # end
  end
end

