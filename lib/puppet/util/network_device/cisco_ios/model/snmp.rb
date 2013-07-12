require 'puppet/util/network_device/ipcalc'
require 'puppet/util/network_device/cisco_ios/model'
require 'puppet/util/network_device/cisco_ios/model/base'
require 'puppet/util/network_device/cisco_ios/model/generic_value'

class Puppet::Util::NetworkDevice::Cisco_ios::Model::Snmp < Puppet::Util::NetworkDevice::Cisco_ios::Model::Base

  attr_reader :params, :name

  def initialize(transport, facts, options)
    super(transport, facts)
    # Initialize some defaults
    @params         ||= {}
    @name           = options[:name] if options.key? :name

    # Register all needed Modules based on the availiable Facts
    register_modules
  end

  def mod_path_base
    return 'puppet/util/network_device/cisco_ios/model/snmp'
  end

  def mod_const_base
    return Puppet::Util::NetworkDevice::Cisco_ios::Model::Snmp
  end

  def param_class
    return Puppet::Util::NetworkDevice::Cisco_ios::Model::GenericValue
  end

  def register_modules
    register_new_module(:base)
  end
end
