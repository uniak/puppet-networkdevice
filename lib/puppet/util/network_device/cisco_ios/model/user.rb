require 'erb'
require 'puppet/util/network_device/ipcalc'
require 'puppet/util/network_device/cisco_ios/model'
require 'puppet/util/network_device/cisco_ios/model/base'
require 'puppet/util/network_device/cisco_ios/model/string_value'

class Puppet::Util::NetworkDevice::Cisco_ios::Model::User < Puppet::Util::NetworkDevice::Cisco_ios::Model::Base

  attr_reader :params, :name
  attr_accessor :base_cmd

  def initialize(transport, facts, options)
    super(transport, facts)
    # Initialize some defaults
    @params         ||= {}
    @name           = options[:name] if options.key? :name

    # Register all needed Modules based on the availiable Facts
    register_modules
  end

  # Since we have to construct a single string of our Options override update here
  # to implent the needed custom logic
  # TODO: Extract the Common behaviour into seperated Methods
  # that can be overloaded so we dont have all that duplication
  def update(is = {}, should = {})
    return unless configuration_changed?(is, should, :keep_ensure => true)
    missing_commands = [is.keys, should.keys].flatten.uniq.sort - @params.keys.flatten.uniq.sort
    missing_commands.delete(:ensure)
    raise Puppet::Error, "Undefined commands for #{missing_commands.join(', ')}" unless missing_commands.empty?
    [is.keys, should.keys].flatten.uniq.sort.each do |property|
      next if should[property] == :undef
      @params[property].value = :absent if should[property] == :absent
      @params[property].value = should[property] unless should[property] == :absent || should[property].nil?
    end
    before_update
    perform_update
    after_update
  end

  def mod_path_base
    return 'puppet/util/network_device/cisco_ios/model/user'
  end

  def mod_const_base
    return Puppet::Util::NetworkDevice::Cisco_ios::Model::User
  end

  def param_class
    return Puppet::Util::NetworkDevice::Cisco_ios::Model::StringValue
  end

  def register_modules
    register_new_module(:base)
  end
end
