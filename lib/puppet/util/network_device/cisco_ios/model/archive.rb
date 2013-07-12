require 'puppet/util/network_device/cisco_ios/model'
require 'puppet/util/network_device/cisco_ios/model/base'
require 'puppet/util/network_device/cisco_ios/model/scoped_value'

class Puppet::Util::NetworkDevice::Cisco_ios::Model::Archive < Puppet::Util::NetworkDevice::Cisco_ios::Model::Base

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
    return 'puppet/util/network_device/cisco_ios/model/archive'
  end

  def mod_const_base
    return Puppet::Util::NetworkDevice::Cisco_ios::Model::Archive
  end

  def param_class
    return Puppet::Util::NetworkDevice::Cisco_ios::Model::ScopedValue
  end

  def register_modules
    register_new_module(:base)
  end

  def before_update
    super
    transport.command("archive", :prompt => /\(config-archive\)#\s?\z/n)
  end

  def after_update
    transport.command("exit")
    super
  end
end
