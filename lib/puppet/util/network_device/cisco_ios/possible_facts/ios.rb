require 'puppet/util/network_device/cisco_ios/possible_facts'

module Puppet::Util::NetworkDevice::Cisco_ios::PossibleFacts::Ios
  def self.register(base)
    base.register_module_after 'operatingsystemmajrelease', 'v12', 'ios' do
      !!(base.facts['operatingsystemmajrelease'].value =~ /^12/)
    end
  end
end
