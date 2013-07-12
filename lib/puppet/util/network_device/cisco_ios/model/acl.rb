require 'puppet/util/network_device/ipcalc'
require 'puppet/util/network_device/cisco_ios/model'
require 'puppet/util/network_device/cisco_ios/model/base'
require 'puppet/util/network_device/cisco_ios/model/string_value'

class Puppet::Util::NetworkDevice::Cisco_ios::Model::Acl < Puppet::Util::NetworkDevice::Cisco_ios::Model::Base

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
    return 'puppet/util/network_device/cisco_ios/model/acl'
  end

  def mod_const_base
    return Puppet::Util::NetworkDevice::Cisco_ios::Model::Acl
  end

  def param_class
    return Puppet::Util::NetworkDevice::Cisco_ios::Model::ScopedValue
  end

  def update(is = {}, should = {})
    return unless configuration_changed?(is, should)

    should_present = should[:ensure] == :present
    is.delete(:ensure)
    should.delete(:ensure)

    missing_commands = [is.keys, should.keys].flatten.uniq.sort - @params.keys.flatten.uniq.sort
    missing_commands.delete(:name)

    raise Puppet::Error, "Undefined commands for #{missing_commands.join(', ')}" unless missing_commands.empty?

    [is.keys, should.keys].flatten.uniq.sort.each do |property|
      next if property == :ensure || property == :name
      next if should[property] == :undef
      if should[property] == :absent || should[property].nil? then
        @params[property].value = :absent
      else
        @params[property].value = should[property]
      end
    end

    before_update
    if should_present then
      transport.command("ip access-list standard #{@name}", :prompt => /\(config-std-nacl\)#\z/n)
      Puppet::Util::NetworkDevice::Sorter.new(@params).tsort.each do |param|
        # We dont want to change undefined values
        next if should[param.name] == :undef || should[param.name].nil?
        param.update(@transport, is[param.name]) unless is[param.name] == should[param.name]
      end
      transport.command("exit")
    else
      remove_acl(is)
    end
    after_update
  end

  def remove_acl(is)
    transport.command("no ip access-list #{is[:type]} #{is[:name]}")
  end

  def register_modules
    register_new_module(:base)
  end
end
