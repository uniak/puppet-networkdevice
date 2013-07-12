require 'puppet/util/network_device/ipcalc'
require 'puppet/util/network_device/cisco_ios/model'
require 'puppet/util/network_device/cisco_ios/model/base'
require 'puppet/util/network_device/cisco_ios/model/string_value'

class Puppet::Util::NetworkDevice::Cisco_ios::Model::Aaa_group < Puppet::Util::NetworkDevice::Cisco_ios::Model::Base

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
    return 'puppet/util/network_device/cisco_ios/model/aaa_group'
  end

  def mod_const_base
    return Puppet::Util::NetworkDevice::Cisco_ios::Model::Aaa_group
  end

  def param_class
    return Puppet::Util::NetworkDevice::Cisco_ios::Model::StringValue
  end

  def register_modules
    register_new_module(:base)
  end

  # Since we have to construct a single string of our Options override update here
  # to implent the needed custom logic
  # TODO: Extract the Common behaviour into seperated Methods
  # that can be overloaded so we dont have all that duplication
  def update(is = {}, should = {})
    return unless configuration_changed?(is, should)
    before_update
    if should[:ensure] == :present
      missing_commands = [is.keys, should.keys].flatten.uniq.sort - @params.keys.flatten.uniq.sort
      missing_commands.delete(:name)
      missing_commands.delete(:protocol)
      missing_commands.delete(:ensure)
      raise Puppet::Error, "Undefined commands for #{missing_commands.join(', ')}" unless missing_commands.empty?
      [is.keys, should.keys].flatten.uniq.sort.each do |property|
        next if should[property] == :undef
        @params[property].value = :absent if should[property] == :absent || should[property].nil?
        @params[property].value = should[property] unless should[property] == :absent || should[property].nil?
      end
      transport.command("aaa group server #{should[:protocol]} #{@name}", :prompt => /\(config-sg-#{should[:protocol]}\)#\z/n)
      transport.command(construct_server_cmd)
      transport.command("exit")
      [:local_authentication, :local_authorization].each do |auth|
        if !is[auth] and should[auth]
          @params[auth].update(@transport, is[auth])
        end
      end
    else
      transport.command("no aaa group server #{is[:protocol]} #{@name}")
    end
    after_update
  end

  def construct_server_cmd
    p = {
      :server => @params[:server],
      :acct_port => @params[:acct_port],
      :auth_port => @params[:auth_port],
    }
    Puppet::Util::NetworkDevice::Sorter \
      .new(p) \
      .tsort \
      .collect { |p| p.get_fragment if p.fragment and p.value and p.supported? } \
      .reject { |f| f.nil? } \
      .join " "
  end
end
