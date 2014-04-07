require 'puppet/util/network_device/cisco_ios/model'
require 'puppet/util/network_device/cisco_ios/model/aaa_group'
require 'puppet/util/network_device/cisco_ios/model/acl'
require 'puppet/util/network_device/cisco_ios/model/archive'
require 'puppet/util/network_device/cisco_ios/model/base'
require 'puppet/util/network_device/cisco_ios/model/generic_value'
require 'puppet/util/network_device/cisco_ios/model/hsrp_standby_group'
require 'puppet/util/network_device/cisco_ios/model/interface'
require 'puppet/util/network_device/cisco_ios/model/radius_server'
require 'puppet/util/network_device/cisco_ios/model/snmp'
require 'puppet/util/network_device/cisco_ios/model/snmp_community'
require 'puppet/util/network_device/cisco_ios/model/snmp_host'
require 'puppet/util/network_device/cisco_ios/model/user'
require 'puppet/util/network_device/cisco_ios/model/vlan'
require 'puppet/util/network_device/ipcalc'

class Puppet::Util::NetworkDevice::Cisco_ios::Model::Switch < Puppet::Util::NetworkDevice::Cisco_ios::Model::Base

  attr_reader :params, :vlans

  def initialize(transport, facts)
    super
    # Initialize some defaults
    @params         ||= {}
    @vlans          ||= []
    # Register all needed Modules based on the availiable Facts
    register_modules
  end

  def mod_path_base
    return 'puppet/util/network_device/cisco_ios/model/switch'
  end

  def mod_const_base
    return Puppet::Util::NetworkDevice::Cisco_ios::Model::Switch
  end

  def param_class
    return Puppet::Util::NetworkDevice::Cisco_ios::Model::GenericValue
  end

  def register_modules
    register_new_module(:base)
  end

  def skip_params_to_hash
    [ :snmp, :archive ]
  end

  def interface(name)
    int = params[:interfaces].value.find { |int| int.name == name }
    int.evaluate_new_params if int
    int
  end

  def hsrp_standby_group(name)
    grp = params[:hsrp_standby_groups].value.find { |g| g.name == name } || Puppet::Util::NetworkDevice::Cisco_ios::Model::HsrpStandbyGroup.new(transport, facts, {:name => name})
    grp.evaluate_new_params
    grp
  end

  [ :aaa_group,
    :acl,
    :user,
    :vlan,
    :vrf,
    :radius_server,
    :snmp_community,
    :snmp_host,
  ].each do |key|
    define_method key.to_s do |name|
      grp = params[key].value.find { |g| g.name == name }
      if grp.nil?
        grp = Puppet::Util::NetworkDevice::Cisco_ios::Model.const_get(key.to_s.capitalize).new(transport, facts, {:name => name})
        params[key].value << grp
      end
      grp.evaluate_new_params
      return grp
    end
  end

  def line(name)
    line = params[:lines].value.find { |l| l.name == name }
    line.evaluate_new_params
    return line
  end

  def snmp(name)
    unless params[:snmp]
      params[:snmp] = Puppet::Util::NetworkDevice::Cisco_ios::Model::Snmp.new(transport, facts, {:name => name})
      params[:snmp].evaluate_new_params
    end
    return params[:snmp]
  end

  def archive(name)
    unless params[:archive]
      params[:archive] = Puppet::Util::NetworkDevice::Cisco_ios::Model::Archive.new(transport, facts, { :name => name })
      params[:archive].evaluate_new_params
    end
    return params[:archive]
  end
end
