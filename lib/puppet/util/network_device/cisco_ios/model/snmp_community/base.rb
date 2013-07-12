require 'puppet/util/network_device/cisco_ios/model'
require 'puppet/util/network_device/cisco_ios/model/snmp_community'

module Puppet::Util::NetworkDevice::Cisco_ios::Model::SnmpCommunity::Base
  def self.register(base)
    base.base_cmd = "snmp-server community <%= name %>"
    snmp_scope = /^(snmp-server community (\S+)(.*))/
    base.register_scoped :ensure, snmp_scope do
      match do |txt|
        unless txt.nil?
          txt.match(/\S+/) ? :present : :absent
        else
          :absent
        end
      end
      cmd 'sh run'
      default :absent
    end
    base.register_scoped :view, snmp_scope do
      match /\s*(?:view (\S+))?\s*(\S{2})?\s*(\S+)?$/
      cmd 'sh run'
      idx 0
      supported true
      fragment "view <%= value %>"
    end
    base.register_scoped :perm, snmp_scope do
      match do |txt|
        view = txt.scan(/\s*(?:view (\S+))?\s*(\S{2})?\s*(\S+)?$/).flatten[1]
        view.downcase.to_sym unless view.nil? || view.empty?
      end
      cmd 'sh run'
      supported true
      fragment "<%= value %>"
      after :view
    end
    base.register_scoped :acl, snmp_scope do
      match /\s*(?:view (\S+))?\s*(\S{2})?\s*(\S+)?$/
      cmd 'sh run'
      idx 2
      supported true
      fragment "<%= value %>"
      after :perm
    end
  end
end

