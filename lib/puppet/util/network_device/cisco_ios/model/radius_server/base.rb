require 'puppet/util/network_device/cisco_ios/model'
require 'puppet/util/network_device/cisco_ios/model/radius_server'

module Puppet::Util::NetworkDevice::Cisco_ios::Model::Radius_server::Base
  def self.register(base)
    base.base_cmd = "radius-server host <%= name %>"
    scope = /^(radius-server host (\S+)(.*))/

    base.register_scoped :ensure, scope do
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

    base.register_scoped :acct_port, scope do
      match /acct-port (\d+)/
      cmd 'sh run'
      supported true
      fragment "acct-port <%= value %>"
    end

    base.register_scoped :auth_port, scope do
      match /auth-port (\d+)/
      cmd 'sh run'
      supported true
      fragment "auth-port <%= value %>"
      after :acct_port
    end

    base.register_scoped :key_type, scope do
      match /key (\d{1}) \S+/
      cmd 'sh run'
      supported true
      fragment "key <%= value %>"
      after :auth_port
    end

    base.register_scoped :key, scope do
      match /key \d{1} (\S+)/
      cmd 'sh run'
      supported true
      fragment "<%= value %>"
      after :key_type
    end
  end
end
