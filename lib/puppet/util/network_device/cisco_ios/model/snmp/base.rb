require 'puppet/util/network_device/cisco_ios/model'
require 'puppet/util/network_device/cisco_ios/model/snmp'

module Puppet::Util::NetworkDevice::Cisco_ios::Model::Snmp::Base
  def self.snmp_prop(base, param, base_command = param, &block)
    base.register_param param do
      cmd 'sh run'
      match /^\s*#{base_command}\s+(.*)$/
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
    snmp_prop(base, :chassis_id, 'snmp-server chassis-id')
    snmp_prop(base, :contact, 'snmp-server contact')
    snmp_prop(base, :enable_traps, 'snmp-server enable traps') do
      match do |txt|
        traps = txt.scan(/^snmp-server enable traps (.*)$/).flatten
        traps.empty? ? nil : traps
      end
    end
    snmp_prop(base, :engineid_local, 'snmp-server engineID local')
# TODO: Should be extracted into a seperate Type
#    snmp_prop(base, :engineid_remote, 'snmp-server engineID remote')
    snmp_prop(base, :file_transfer_access_group, 'snmp-server file-transfer access-group')
    snmp_prop(base, :ifindex_persist) do
      match do |txt|
        matched = false
        # cisco magic number ... *sigh*
        [/^snmp-server ifindex persist$/, /^snmp ifmib ifindex persist$/].each do |reg|
          if txt.match(reg)
            matched = true
          end
        end
        matched ? :present : :absent
      end
      add do |transport, _|
        transport.command('snmp-server ifindex persist')
      end
      remove do |transport, _|
        transport.command('no snmp-server ifindex persist')
      end
    end
    snmp_prop(base, :inform_pending, 'snmp-server inform pending')
    snmp_prop(base, :inform_retries, 'snmp-server inform retries')
    snmp_prop(base, :inform_timeout, 'snmp-server inform timeout')
    snmp_prop(base, :ip_dscp, 'snmp-server ip dscp')
    snmp_prop(base, :ip_precedence, 'snmp-server ip precedence')
    snmp_prop(base, :location, 'snmp-server location')
    snmp_prop(base, :manager) do
      match do |txt|
        txt.match(/^snmp-server manager$/) ? :present : :absent
      end
      add do |transport, _|
        transport.command('snmp-server manager')
      end
      remove do |transport, _|
        transport.command('no snmp-server manager')
      end
    end
    snmp_prop(base, :manager_session_timeout, 'snmp-server manager session-timeout')
    snmp_prop(base, :packetsize, 'snmp-server packetsize')
    snmp_prop(base, :queue_length, 'snmp-server queue-length')
    snmp_prop(base, :source_interface_informs, 'snmp-server source-interface informs')
    snmp_prop(base, :source_interface_traps, 'snmp-server source-interface traps')
    snmp_prop(base, :system_shutdown) do
      match do |txt|
        txt.match(/^snmp-server system-shutdown$/) ? :present : :absent
      end
      add do |transport, _|
        transport.command('snmp-server system-shutdown')
      end
      remove do |transport, _|
        transport.command('no snmp-server system-shutdown')
      end
    end
    snmp_prop(base, :tftp_server_list, 'snmp-server tftp-server-list')
    snmp_prop(base, :trap_source, 'snmp-server trap-source')
    snmp_prop(base, :trap_timeout, 'snmp-server trap-timeout')
  end
end
