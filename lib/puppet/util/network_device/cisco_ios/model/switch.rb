require 'puppet/util/network_device/ipcalc'
require 'puppet/util/network_device/cisco_ios/model'
require 'puppet/util/network_device/cisco_ios/model/archive'
require 'puppet/util/network_device/cisco_ios/model/vlan'
require 'puppet/util/network_device/cisco_ios/model/user'
require 'puppet/util/network_device/cisco_ios/model/radius_server'
require 'puppet/util/network_device/cisco_ios/model/snmp_community'
require 'puppet/util/network_device/cisco_ios/model/snmp_host'
require 'puppet/util/network_device/cisco_ios/model/snmp'
require 'puppet/util/network_device/cisco_ios/model/interface'
require 'puppet/util/network_device/cisco_ios/model/base'
require 'puppet/util/network_device/cisco_ios/model/generic_value'

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
    int.evaluate_new_params
    return int
  end

  def aaa_group(name)
    grp = params[:aaa_groups].value.find { |g| g.name == name }
    if grp.nil?
      grp = Puppet::Util::NetworkDevice::Cisco_ios::Model::Aaa_group.new(transport, facts, {:name => name})
      params[:aaa_groups].value << grp
    end
    grp.evaluate_new_params
    return grp
  end

  def acl(name)
    acl = params[:acl].value.find { |a| a.name == name }
    if acl.nil?
      acl = Puppet::Util::NetworkDevice::Cisco_ios::Model::Acl.new(transport, facts, {:name => name})
      params[:acl].value << acl
    end
    acl.evaluate_new_params
    return acl
  end

  def user(name)
    user = params[:user].value.find { |u| u.name == name }
    if user.nil?
      user = Puppet::Util::NetworkDevice::Cisco_ios::Model::User.new(transport, facts, {:name => name})
      params[:user].value << user
    end
    user.evaluate_new_params
    return user
  end

  def vlan(name)
    vlan = params[:vlan].value.find { |v| v.name == name }
    if vlan.nil?
      vlan = Puppet::Util::NetworkDevice::Cisco_ios::Model::Vlan.new(transport, facts, {:name => name})
      params[:vlan].value << vlan
    end
    vlan.evaluate_new_params
    return vlan
  end

  def radius_server(name)
    radius = params[:radius_server].value.find { |rs| rs.name == name }
    if radius.nil?
      radius = Puppet::Util::NetworkDevice::Cisco_ios::Model::RadiusServer.new(transport, facts, {:name => name})
      params[:radius_server].value << radius
    end
    radius.evaluate_new_params
    return radius
  end

  def line(name)
    line = params[:lines].value.find { |l| l.name == name }
    line.evaluate_new_params
    return line
  end

  def snmp_community(name)
    snmp = params[:snmp_communities].value.find { |snmp| snmp.name == name }
    if snmp.nil?
      snmp = Puppet::Util::NetworkDevice::Cisco_ios::Model::SnmpCommunity.new(transport, facts, {:name => name})
      params[:snmp_communities].value << snmp
    end
    snmp.evaluate_new_params
    return snmp
  end

  def snmp_host(name)
    snmp = params[:snmp_hosts].value.find { |snmp| snmp.name == name }
    if snmp.nil?
      snmp = Puppet::Util::NetworkDevice::Cisco_ios::Model::SnmpHost.new(transport, facts, {:name => name})
      params[:snmp_hosts].value << snmp
    end
    snmp.evaluate_new_params
    return snmp
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
