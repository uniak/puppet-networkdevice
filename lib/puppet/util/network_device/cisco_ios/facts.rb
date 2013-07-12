require 'puppet/util/network_device/cisco_ios'
require 'puppet/util/network_device/cisco_ios/fact'
require 'puppet/util/network_device/cisco_ios/possible_facts'
require 'puppet/util/network_device/sorter'
require 'puppet/util/network_device/dsl'

class Puppet::Util::NetworkDevice::Cisco_ios::Facts

  include Puppet::Util::NetworkDevice::Dsl

  attr_reader :transport

  def initialize(transport)
    @transport = transport
  end

  def mod_path_base
    return 'puppet/util/network_device/cisco_ios/possible_facts'
  end

  def mod_const_base
    return Puppet::Util::NetworkDevice::Cisco_ios::PossibleFacts
  end

  def param_class
    return Puppet::Util::NetworkDevice::Cisco_ios::Fact
  end

  # TODO
  def facts
    @params
  end

  def facts_to_hash
    params_to_hash
  end
end
