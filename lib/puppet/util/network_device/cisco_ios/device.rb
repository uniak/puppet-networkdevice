require 'puppet'
require 'puppet/util'
require 'puppet/util/network_device/base_ios'
require 'puppet/util/network_device/cisco_ios/cisco_config'
require 'puppet/util/network_device/cisco_ios/interface'
require 'puppet/util/network_device/cisco_ios/facts'
require 'puppet/util/network_device/cisco_ios/model'
require 'puppet/util/network_device/cisco_ios/model/switch'

class Puppet::Util::NetworkDevice::Cisco_ios::Device < Puppet::Util::NetworkDevice::Base_ios

  attr_accessor :enable_password, :switch

  def initialize(url, options = {})
    super(url)
    @enable_password = options[:enable_password] || parse_enable(@url.query)
    @initialized = false
    transport.default_prompt = /[#>]\s?\z/n
  end

  def parse_enable(query)
    return $1 if query =~ /enable=(.*)/
  end

  def connect_transport
    transport.connect
    login
    transport.command("terminal length 0", :noop => false) do |out|
      enable if out =~ />\s?\z/n
    end
  end

  def login
    return if transport.handles_login?
    if @url.user != ''
      transport.command(@url.user, {:prompt => /^Password:/, :noop => false})
    else
      transport.expect(/^Password:/)
    end
    transport.command(@url.password, :noop => false)
  end

  def enable
    raise "Can't issue \"enable\" to enter privileged, no enable password set" unless enable_password
    transport.command("enable", {:prompt => /^Password:/, :noop => false})
    transport.command(enable_password, :noop => false)
  end

  def init
    # TODO: Stop being an Idiot ...
    unless @initialized
      connect_transport
      init_facts
      init_switch
      @initialized = true
    end
    return self
  end

  def init_switch
    @switch ||= Puppet::Util::NetworkDevice::Cisco_ios::Model::Switch.new(transport, @facts.facts_to_hash)
    @switch.retrieve
  end

  def init_facts
    @facts ||= Puppet::Util::NetworkDevice::Cisco_ios::Facts.new(transport)
    @facts.retrieve
  end

  def facts
    # This is here till we can fork Puppet
    init
    @facts.facts_to_hash
  end
end
