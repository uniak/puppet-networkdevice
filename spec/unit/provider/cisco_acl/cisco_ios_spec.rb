#! /usr/bin/env ruby
require 'spec_helper'

require 'puppet/provider/cisco_acl/cisco_ios'

provider_class = Puppet::Type.type(:cisco_acl).provider(:cisco_ios)

describe provider_class do
  before do
    @acl = stub_everything 'acl network'
    @acl.stubs(:name).returns('NETWORK')
    @acl.stubs(:params_to_hash)
    @acls = [ @acl ]

    @switch = stub_everything 'switch'
    @switch.stubs(:acls).returns(@acls)
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

    it "should delegate to the device acl fetcher" do
      @device.expects(:switch).returns(@switch)
      @switch.expects(:acl).with('NETWORK').returns(@acl)
      @acl.expects(:params_to_hash)
      provider_class.lookup(@device, 'NETWORK')
    end

    it "should return the given configuration data" do
      @device.expects(:switch).returns(@switch)
      @switch.expects(:acl).with('NETWORK').returns(@acl)
      @acl.expects(:params_to_hash).returns({:type => 'standard'})
      provider_class.lookup(@device, 'NETWORK').should == { :type => 'standard' }
    end
  end

  describe "when the configuration is being flushed" do
    it "should call the device configuration update method with current and past properties" do
      @instance = provider_class.new(@device, :ensure => :present, :name => "NETWORK", :type => "standard", :acl => [ 'permit myserver', 'deny evilcorp' ])
      @instance.resource = @resource
      @resource.stubs(:[]).with(:name).returns('NETWORK')
      @instance.stubs(:device).returns(@device)
      @switch.expects(:acl).with('NETWORK').returns(@acl)
      @acl.expects(:update).with(
        {:ensure => :present, :name => "NETWORK", :type => 'standard', :acl => [ 'permit myserver', 'deny evilcorp' ] },
        {:ensure => :present, :name => "NETWORK", :type => 'standard', :acl => [ 'permit myserver', 'deny evilcorp', 'permit foo' ] })

      @instance.acl = [ 'permit myserver', 'deny evilcorp', 'permit foo' ]
      @instance.flush
    end
  end
end
