require 'puppet/util/network_device/dsl'
require 'puppet/util/network_device/cisco_ios/model'
require 'puppet/util/network_device/sorter'

class Puppet::Util::NetworkDevice::Cisco_ios::Model::Base

  include Puppet::Util::NetworkDevice::Dsl

  attr_accessor :ensure, :name, :transport, :facts

  def initialize(transport, facts)
    @transport = transport
    @facts = facts
  end

  def update(is = {}, should = {})
    return unless configuration_changed?(is, should)
    missing_commands = [is.keys, should.keys].flatten.uniq.sort - @params.keys.flatten.uniq.sort
    missing_commands.delete(:ensure)
    raise Puppet::Error, "Undefined commands for #{missing_commands.join(', ')}" unless missing_commands.empty?
    [is.keys, should.keys].flatten.uniq.sort.each do |property|
      next if property == :ensure
      next if should[property] == :undef
      @params[property].value = :absent if should[property] == :absent || should[property].nil?
      @params[property].value = should[property] unless should[property] == :absent || should[property].nil?
    end
    before_update
    Puppet::Util::NetworkDevice::Sorter.new(@params).tsort.each do |param|
      # We dont want to change undefined values
      next if should[param.name] == :undef || should[param.name].nil?
      param.update(@transport, is[param.name]) unless is[param.name] == should[param.name]
    end
    after_update
  end

  def configuration_changed?(is, should, options = {})
    # Dup the Vars so we dont modify the orig. values
    is = is.dup.delete_if {|k,v| v == :undef || should[k] == :undef}
    is.delete_if {|k,v| k == :ensure} unless options[:keep_ensure]
    should = should.dup.delete_if {|k,v| v == :undef}
    should.delete_if {|k,v| k == :ensure} unless options[:keep_ensure]
    is != should
  end

  def mod_path_base
    raise Puppet::Error, 'Override me'
  end

  def mod_const_base
    raise Puppet::Error, 'Override me'
  end

  def param_class
    raise Puppet::Error, 'Override me'
  end

  def before_update
    transport.command("conf t", :prompt => /\(config\)#\s?\z/n)
  end

  def after_update
    transport.command("end")
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

  def perform_update
    case @params[:ensure].value
    when :present
      transport.command(construct_cmd)
    when :absent
      transport.command("no " + construct_cmd)
    end
  end
end
