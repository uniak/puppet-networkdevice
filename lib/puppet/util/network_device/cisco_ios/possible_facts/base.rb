require 'puppet/util/network_device/cisco_ios/possible_facts'

module Puppet::Util::NetworkDevice::Cisco_ios::PossibleFacts::Base
  def self.register(base)
    base.register_param ['hardwaremodel', 'processor', 'hardwarerevision', 'memorysize'] do
      match /[cC]isco ([\S-]+) (?:\(([\w-]+)\) processor )?\(revision (.+)\) with (\d+[KMG])(?:\/(\d+[KMG]))? bytes of memory\./
      cmd "sh ver"
    end

    base.register_param 'canonicalized_hardwaremodel' do
      match do |hardwaremodel|
        canonicalize_hardwaremodel(hardwaremodel)
      end
      cmd false
      match_param 'hardwaremodel'
      after 'hardwaremodel'
    end

    base.register_param ['hostname', 'uptime'] do
      match /^\s*([\w-]+)\s+uptime is (.*?)$/
      cmd "sh ver"
      after 'domain'
      downcase true
    end

    base.register_param 'domain' do
      match /^ip\s+domain-name\s+(.*)$/
      cmd "sh run"
      downcase true
    end

    base.register_param 'fqdn' do
      match do |hostname, domain|
        "#{hostname}.#{domain}" unless hostname.nil? or domain.nil?
      end
      cmd false
      match_param [ 'hostname', 'domain' ]
      after 'hostname'
    end

    base.register_param 'uptime_seconds' do
      match do |uptime|
        uptime_to_seconds(uptime)
      end
      cmd false
      match_param 'uptime'
      after 'uptime'
    end

    base.register_param 'uptime_days' do
      match do |uptime_seconds|
        (uptime_seconds / 86400) if uptime_seconds
      end
      cmd false
      match_param 'uptime_seconds'
      after 'uptime_seconds'
    end

    base.register_param ['operatingsystem', 'operatingsystemplatform', 'operatingsystemxeplatform', 'operatingsystemfeature', 'operatingsystemrelease'] do
      match /^(?:Cisco )?(IOS)\s*(?:\(tm\) |Software, )?(\S+)\s+Software,?\s+(?:Catalyst\s+(\d+))?(?:.*)\(\w+-(\w+)-\w+\), Version ([0-9.()A-Za-z]+)\.?/
      cmd "sh ver"
    end

    base.register_param 'operatingsystemmajrelease' do
      match do |operatingsystemrelease|
        ios_major_version(operatingsystemrelease)
      end
      cmd false
      match_param 'operatingsystemrelease'
      after 'operatingsystemrelease'
    end

    base.register_param 'system_image' do
      match do |txt|
        matched = txt.match(/^[sS]ystem image file is "(\S+)"$/)
        # TODO: SPEC
        matched.nil? ? "" : File.basename(matched.captures.first)
      end
      cmd "sh ver"
    end

    base.register_param 'configuration_register' do
      match /^Configuration\s+register\s+is\s+(\S+)$/
      cmd "sh ver"
    end

    base.register_param 'processor_board_id' do
      match /^Processor\s+board\s+ID\s(\S+)$/
      cmd "sh ver"
    end

    base.register_param 'ethernet_interfaces' do
      match do |txt|
        txt.scan(/^(\d+)\s+(.+)\s*Ethernet\s+interfaces$/).inject({}) do |res, (num, type)|
          res[type.downcase.split.join("_") + "_ethernet"] = num
          res
        end
      end
      cmd "sh ver"
    end

    base.register_param 'inventory' do
      match do |txt|
        txt.split(/^$/).map do |line|
          line.scan(/(\S+):\s+"(.+)",\s+(\S+):\s+"(.+)"\n(\S+):\s+(\S+)\s+,\s+(\S+):\s+(\S+)?\s+,\s+(\S+):\s+(\S+)\s+$/).flatten.map do |item|
            item.strip unless item.nil?
          end
        end.delete_if {|x| x.empty?}.inject({}) do |res, data|
          prefix = data[1].downcase.gsub(/(\(|\)|\/|\s)/, '_').gsub(/_$/, '')
          data[2..-1].each_slice(2) do |name, val|
            res["inventory_#{prefix}_" + name.downcase] = val
          end
          res
        end
      end
      cmd "sh inventory"
    end

    base.register_param 'vtp_mode' do
      match do |txt|
        txt.scan(/^VTP Operating Mode\s+:\s(.+)$/).flatten.first.gsub(/ /, '_').downcase
      end
      cmd 'sh vtp status'
    end

    base.register_param 'vtp_version' do
      match do |txt|
        txt.scan(/^VTP version running\s+:\s+(\d)$/).flatten.first
      end
      cmd 'sh vtp status'
    end

    base.register_param 'vtp_domain' do
      match do |txt|
        txt.scan(/^VTP Domain Name\s+:\s+(\S+)$/).flatten.first
      end
      cmd 'sh vtp status'
    end

    base.register_param 'interfaces' do
      match do |txt|
        Hash[*txt.scan(/^(?:\*)?\s+(\S+)/).flatten.map do |line|
          line.scan(/(\D+)(\d+)\/?.*$/).flatten
        end.map do |arr|
          arr.join
        end.delete_if do |arr|
          arr.empty?
        end.group_by do |arr|
          arr
        end.map do |k,v|
          ["interfaces_" + k.downcase.scan(/(\D+)(\d+)/).flatten.join("_"), v.length.to_s]
        end.flatten]
      end
      cmd "sh interfaces summary"
    end

    base.register_module_after 'operatingsystem', 'ios' do
      base.facts['operatingsystem'].value == "IOS"
    end

    base.register_module_after 'operatingsystemplatform', 'iosxe' do
      base.facts['operatingsystemplatform'].value == "IOS-XE"
    end

    base.register_module_after 'canonicalized_hardwaremodel', 'c4500', 'hardware' do
      base.facts['canonicalized_hardwaremodel'].value == 'c4500'
    end

    base.register_module_after 'canonicalized_hardwaremodel', 'c3750', 'hardware' do
      base.facts['canonicalized_hardwaremodel'].value == 'c3750'
    end
  end
end
