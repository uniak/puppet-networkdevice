#! /usr/bin/env ruby
require 'spec_helper'

require 'puppet/provider/cisco_vlan/cisco_ios'

provider_class = Puppet::Type.type(:cisco_vlan).provider(:cisco_ios)

describe provider_class do
  before do
    @vlan = stub_everything 'vlan'
    @vlan.stubs(:name).returns('1100')
    @vlan.stubs(:params_to_hash)
    @vlans = [ @vlan ]

    @switch = stub_everything 'switch'
    @switch.stubs(:vlan).returns(@vlans)
    @switch.stubs(:params_to_hash).returns({})

    @device = stub_everything 'device'
    @device.stubs(:switch).returns(@switch)

    @resource = stub('resource', :desc => "INT")

    @provider = provider_class.new(@device, @resource)
  end

  it "should have a parent of Puppet::Provider::Cisco_ios" do
    provider_class.should < Puppet::Provider::Cisco_ios
  end

  it "should have an instances method" do
    provider_class.should respond_to(:instances)
  end

  describe "when looking up instances at prefetch" do
    before do
      @device.stubs(:command).yields(@device)
    end

    it "should delegate to the device vlan fetcher" do
      @device.expects(:switch).returns(@switch)
      @switch.expects(:vlan).with('1100').returns(@vlan)
      @vlan.expects(:params_to_hash)
      provider_class.lookup(@device, '1100')
    end

    it "should return the given configuration data" do
      @device.expects(:switch).returns(@switch)
      @switch.expects(:vlan).with('1100').returns(@vlan)
      @vlan.expects(:params_to_hash).returns({ :desc => "INT" })
      provider_class.lookup(@device, '1100').should == { :desc => "INT" }
    end
  end

  describe "when the configuration is being flushed" do
    it "should call the device configuration update method with current and past properties" do
      @instance = provider_class.new(@device, :ensure => :present, :name => '1100', :desc => "INT")
      @instance.resource = @resource
      @resource.stubs(:[]).with(:name).returns('1100')
      @instance.stubs(:device).returns(@device)
      @switch.expects(:vlan).with('1100').returns(@vlan)
      @switch.stubs(:facts).returns({})
      @vlan.expects(:update).with({:ensure => :present, :name => '1100', :desc => "INT"},
                                  {:ensure => :present, :name => '1100', :desc => "FOOBAR"})
      @vlan.expects(:update).never

      @instance.desc = "FOOBAR"
      @instance.flush
    end
  end
end
