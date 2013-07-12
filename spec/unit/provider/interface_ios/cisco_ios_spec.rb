#! /usr/bin/env ruby
require 'spec_helper'

require 'puppet/provider/interface_ios/cisco_ios'

provider_class = Puppet::Type.type(:interface_ios).provider(:cisco_ios)

describe provider_class do
  before do
    @interface = stub_everything 'interface Fe2/0/1'
    @interface.stubs(:name).returns('FastEthernet2/0/1')
    @interface.stubs(:params_to_hash)
    @interfaces = [ @interface ]

    @switch = stub_everything 'switch'
    @switch.stubs(:interfaces).returns(@interfaces)
    @switch.stubs(:params_to_hash).returns({})

    @device = stub_everything 'device'
    @device.stubs(:switch).returns(@switch)

    @resource = stub("resource", :description => "a fast ethernet port")

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

    it "should delegate to the device interface fetcher" do
      @device.expects(:switch).returns(@switch)
      @switch.expects(:interface).with('FastEthernet2/0/1').returns(@interface)
      @interface.expects(:params_to_hash)
      provider_class.lookup(@device, 'FastEthernet2/0/1')
    end

    it "should return the given configuration data" do
      @device.expects(:switch).returns(@switch)
      @switch.expects(:interface).with('FastEthernet2/0/1').returns(@interface)
      @interface.expects(:params_to_hash).returns({ :description => "my description" })
      provider_class.lookup(@device, 'FastEthernet2/0/1').should == { :description => "my description" }
    end
  end

  describe "when the configuration is being flushed" do
    it "should call the device configuration update method with current and past properties" do
      @instance = provider_class.new(@device, :ensure => :present, :name => "FastEthernet2/0/1", :description => "my description")
      @instance.device.expects(:switch).returns(@switch)
      @switch.expects(:interface).with('FastEthernet2/0/1').returns(@interface)
      @interface.expects(:update).with({:ensure => :present, :name => "FastEthernet2/0/1", :description => "my description"},
                                       {:ensure => :present, :name => "FastEthernet2/0/1", :description => "new description"})

      @instance.description = "new description"
      @instance.flush
    end
  end
end
