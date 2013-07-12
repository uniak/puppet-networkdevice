#! /usr/bin/env ruby
require 'spec_helper'

require 'puppet/provider/cisco_aaa_group/cisco_ios'

provider_class = Puppet::Type.type(:cisco_aaa_group).provider(:cisco_ios)

describe provider_class do
  before do
    @aaa_group = stub_everything 'aaa_group network'
    @aaa_group.stubs(:name).returns('NETWORK')
    @aaa_group.stubs(:params_to_hash)
    @aaa_groups = [ @aaa_group ]

    @switch = stub_everything 'switch'
    @switch.stubs(:aaa_groups).returns(@aaa_groups)
    @switch.stubs(:params_to_hash).returns({})

    @device = stub_everything 'device'
    @device.stubs(:switch).returns(@switch)

    @resource = stub("resource", :protocol => "radius")

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

    it "should delegate to the device aaa_group fetcher" do
      @device.expects(:switch).returns(@switch)
      @switch.expects(:aaa_group).with('NETWORK').returns(@aaa_group)
      @aaa_group.expects(:params_to_hash)
      provider_class.lookup(@device, 'NETWORK')
    end

    it "should return the given configuration data" do
      @device.expects(:switch).returns(@switch)
      @switch.expects(:aaa_group).with('NETWORK').returns(@aaa_group)
      @aaa_group.expects(:params_to_hash).returns({:protocol => 'radius'})
      provider_class.lookup(@device, 'NETWORK').should == { :protocol => 'radius' }
    end
  end

  describe "when the configuration is being flushed" do
    it "should call the device configuration update method with current and past properties" do
      @instance = provider_class.new(@device, :ensure => :present, :name => "NETWORK", :protocol => "radius", :server => 'myserver')
      @instance.resource = @resource
      @resource.stubs(:[]).with(:name).returns('NETWORK')
      @instance.stubs(:device).returns(@device)
      @switch.expects(:aaa_group).with('NETWORK').returns(@aaa_group)
      @aaa_group.expects(:update).with( {:ensure => :present, :name => "NETWORK", :protocol => 'radius', :server => "myserver"},
                                     {:ensure => :present, :name => "NETWORK", :protocol => 'radius', :server => "newserver"})

      @instance.server = "newserver"
      @instance.flush
    end
  end
end
