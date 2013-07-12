require 'puppet/util/network_device/cisco_ios/possible_facts'
require 'puppet/util/network_device/cisco_ios/possible_facts/hardware'

module Puppet::Util::NetworkDevice::Cisco_ios::PossibleFacts::Hardware::C4500
  def self.register(base)
    base.register_param 'license_information' do
      match do |txt|
        txt.scan(/^\s+License\s+Level:\s+(\S+)\s+Type:\s+(\S+)$/).flatten.zip(%w{license_level license_type}).inject({}) do |res, (v, k)|
          res[k] = v
          res
        end
      end
      cmd "sh ver"
    end

    base.register_param 'rom' do
      match /^ROM:\s+(\S+)$/
      cmd "sh ver"
    end

    base.register_param ['jawa_revision', 'snowtrooper_revision'] do
      match /^Jawa\s+Revision\s+(\d+),\s+Snowtrooper\s+Revision\s+(\S+)$/
      cmd "sh ver"
    end
  end
end
