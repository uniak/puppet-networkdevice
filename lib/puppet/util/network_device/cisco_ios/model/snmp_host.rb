require 'erb'
require 'puppet/util/network_device/ipcalc'
require 'puppet/util/network_device/cisco_ios/model'
require 'puppet/util/network_device/cisco_ios/model/base'
require 'puppet/util/network_device/cisco_ios/model/string_value'

class Puppet::Util::NetworkDevice::Cisco_ios::Model::SnmpHost < Puppet::Util::NetworkDevice::Cisco_ios::Model::Base

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
    # Delete the Property here since we cant really compare params in a propertys validate block
    # Puppet Magic...
    return unless configuration_changed?(is, should, :keep_ensure => true)
    missing_commands = [is.keys, should.keys].flatten.uniq.sort - @params.keys.flatten.uniq.sort
    missing_commands.delete(:ensure)
    raise Puppet::Error, "Undefined commands for #{missing_commands.join(', ')}" unless missing_commands.empty?
    # We have to remove the old Instance if it exists here before we update the Params so we still can work
    # with the old (parsed) Values
    if update_existing?(is, should)
      before_update
      transport.command("no " + construct_cmd)
      after_update
    end
    [is.keys, should.keys].flatten.uniq.sort.each do |property|
      next if should[property] == :undef
      @params[property].value = should[property] unless should[property].nil?
    end
    before_update
    perform_update
    after_update
  end

  def update_existing?(is, should)
    is[:ensure] == :present && should[:ensure] == :present
  end

  def perform_update
    case @params[:ensure].value
    when :present
      transport.command(construct_cmd)
    when :absent
      transport.command("no " + construct_cmd)
    end
  end

  def get_base_cmd
    raise ArgumentError, "Base Command not set for #{self.class}" if base_cmd.nil?
    ERB.new(base_cmd).result(binding)
  end

  def construct_cmd
    base = get_base_cmd
    Puppet::Util::NetworkDevice::Sorter.new(@params).tsort.each do |param|
      fragment = param.get_fragment if param.fragment and param.value
      base << " #{fragment}" if fragment and param.supported?
    end
    return base
  end

  def mod_path_base
    return 'puppet/util/network_device/cisco_ios/model/snmp_host'
  end

  def mod_const_base
    return Puppet::Util::NetworkDevice::Cisco_ios::Model::SnmpHost
  end

  def param_class
    return Puppet::Util::NetworkDevice::Cisco_ios::Model::StringValue
  end

  def register_modules
    register_new_module(:base)
  end
end
