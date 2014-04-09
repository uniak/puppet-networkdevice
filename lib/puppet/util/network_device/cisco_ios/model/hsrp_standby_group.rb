require 'puppet/util/network_device/ipcalc'
require 'puppet/util/network_device/cisco_ios/model'
require 'puppet/util/network_device/cisco_ios/model/base'
require 'puppet/util/network_device/cisco_ios/model/scoped_value'

class Puppet::Util::NetworkDevice::Cisco_ios::Model::HsrpStandbyGroup < Puppet::Util::NetworkDevice::Cisco_ios::Model::Base

  attr_reader :params, :parent_interface, :standby_group

  def name
    "#{parent_interface}/#{standby_group}"
  end

  def self.parse_title(input)
    matches = /^([-_\w\/]+)\/(\d+)$/.match(input)
    return [matches[1].to_s, matches[2].to_s] if matches
  end

  def initialize(transport, facts, options)
    super(transport, facts)
    # Initialize some defaults
    @params         ||= {}
    @name           = options[:name] if options.key? :name
    # initialise parent_interface/standby_interface from name, if available
    (@parent_interface, @standby_group) = self.class.parse_title(@name) if @name
    @parent_interface        = options[:parent_interface] if options.key? :parent_interface
    @standby_group           = options[:standby_group] if options.key? :standby_group

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
    transport.command("interface #{@parent_interface}", :prompt => /\(config-if\)#\z/n)
  end

  def after_update
    transport.command("exit")
    super
  end

end
