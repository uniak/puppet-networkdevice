require 'puppet/util/network_device/cisco_ios/model'
require 'puppet/util/network_device/cisco_ios/model/user'

module Puppet::Util::NetworkDevice::Cisco_ios::Model::User::Base
  def self.register(base)
    base.base_cmd = "username <%= name %>"
    scope = /^(username (\S+)(.*))/

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

    base.register_scoped :privilege, scope do
      match /privilege (\d+)/
      cmd 'sh run'
      supported true
      fragment "privilege <%= value %>"
    end

    base.register_scoped :password_type, scope do
      match /password (\d{1}) \S+/
      cmd 'sh run'
      supported true
      fragment "password <%= value %>"
      after :privilege
    end

    base.register_scoped :password, scope do
      match /password \d{1} (\S+)/
      cmd 'sh run'
      supported true
      fragment "<%= value %>"
      after :password_type
    end
  end
end

