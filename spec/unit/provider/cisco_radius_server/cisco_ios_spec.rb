#! /usr/bin/env ruby
require 'spec_helper'

require 'puppet/provider/cisco_radius_server/cisco_ios'

provider_class = Puppet::Type.type(:cisco_radius_server).provider(:cisco_ios)

describe provider_class do
  before do
    @rad = stub_everything 'radius server'
    @rad.stubs(:name).returns('127.0.0.1')
    @rad.stubs(:params_to_hash)
    @rad_srv = [ @rad ]

    @switch = stub_everything 'switch'
    @switch.stubs(:radius_server).returns(@rad_srv)
    @switch.stubs(:params_to_hash).returns({})

    @device = stub_everything 'device'
    @device.stubs(:switch).returns(@switch)

    @resource = stub('resource', :key_type => 7, :key => 'ASDF')

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

    it "should delegate to the device radius_server fetcher" do
      @device.expects(:switch).returns(@switch)
      @switch.expects(:radius_server).with('127.0.0.1').returns(@rad)
      @rad.expects(:params_to_hash)
      provider_class.lookup(@device, '127.0.0.1')
    end

    it "should return the given configuration data" do
      @device.expects(:switch).returns(@switch)
      @switch.expects(:radius_server).with('127.0.0.1').returns(@rad)
      @rad.expects(:params_to_hash).returns({ :key_type => 7, :key => 'ASDF' })
      provider_class.lookup(@device, '127.0.0.1').should == { :key_type=> 7, :key => 'ASDF' }
    end
  end

  describe "when the configuration is being flushed" do
    it "should call the device configuration update method with current and past properties" do
      @instance = provider_class.new(@device, :ensure => :present, :name => '127.0.0.1', :key_type => 7, :key => 'ASDF')
      @instance.resource = @resource
      @resource.stubs(:[]).with(:name).returns('127.0.0.1')
      @instance.stubs(:device).returns(@device)
      @switch.expects(:radius_server).with('127.0.0.1').returns(@rad)
      @rad.expects(:update).with({:ensure => :present, :name => '127.0.0.1', :key_type => 7, :key => 'ASDF'},
                                  {:ensure => :present, :name => '127.0.0.1', :key_type => 7, :key => 'ASDF2'})
      @rad.expects(:update).never

      @instance.key = 'ASDF2'
      @instance.flush
    end
  end
end
