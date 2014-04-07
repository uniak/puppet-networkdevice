require 'puppet/util/network_device/ipcalc'
require 'puppet/util/network_device/cisco_ios/model'
require 'puppet/util/network_device/cisco_ios/model/base'
require 'puppet/util/network_device/cisco_ios/model/scoped_value'

class Puppet::Util::NetworkDevice::Cisco_ios::Model::HsrpStandbyGroup < Puppet::Util::NetworkDevice::Cisco_ios::Model::Base

  attr_reader :params, :if_name, :group

  def name
    "#{if_name}/#{group}"
  end

  def initialize(transport, facts, options)
    super(transport, facts)
    # Initialize some defaults
    @params         ||= {}
    @if_name        = options[:if_name] if options.key? :if_name
    @group          = options[:group] if options.key? :group

    # Register all needed Modules based on the availiable Facts
    register_modules
  end

  def mod_path_base
    return 'puppet/util/network_device/cisco_ios/model/hsrp_standby_group'
  end

  def mod_const_base
    return Puppet::Util::NetworkDevice::Cisco_ios::Model::HsrpStandbyGroup
  end

  def param_class
    return Puppet::Util::NetworkDevice::Cisco_ios::Model::ScopedValue
  end

  def register_modules
    register_new_module(:base)
  end

  def before_update
    super
    transport.command("interface #{@if_name}", :prompt => /\(config-if\)#\z/n)
  end

  def after_update
    transport.command("exit")
    super
  end

end
