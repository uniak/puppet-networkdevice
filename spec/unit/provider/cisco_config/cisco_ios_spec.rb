#! /usr/bin/env ruby
require 'spec_helper'
require 'puppet/provider/cisco_config/cisco_ios'

describe Puppet::Type.type(:cisco_config).provider(:cisco_ios) do
  before do
    @device = stub_everything 'device'
    @resource = stub("resource", :name => "running")
    @provider = described_class.new(@device, @resource)
    @switch = stub_everything 'switch'
    @device.stubs(:switch).returns(@switch)
    @switch.stubs(:params_to_hash).returns({})
  end

  it "should have a parent of Puppet::Provider::Cisco_ios" do
    described_class.should < Puppet::Provider::Cisco_ios
  end

  it "should have an instances method" do
    described_class.should respond_to(:instances)
  end

  describe "when looking up instances at prefetch" do
    before do
      @device.stubs(:command).yields(@device)
    end

    it "should delegate to the device interface fetcher" do
      @device.expects(:switch).returns(@switch)
      @switch.expects(:params_to_hash)
      described_class.lookup(@device, :running)
    end

    it "should return the given configuration data" do
      @device.expects(:switch).returns(@switch)
      @switch.expects(:params_to_hash).returns({ :hostname => "myhostname" })
      described_class.lookup(@device, :running).should == { :hostname => "myhostname" }
    end
  end

  describe "when the configuration is being flushed" do
    it "should call the device configuration update method with current and past properties" do
      @instance = described_class.new(@device, :ensure => :present, :name => "running", :hostname => "myhostname")
      @instance.resource = @resource
      @resource.stubs(:[]).with(:name).returns(:running)
      @instance.stubs(:device).returns(@device)
      @switch.expects(:update).with( {:ensure => :present, :name => "running", :hostname => "myhostname"},
                                          {:ensure => :present, :name => "running", :hostname => "newhostname"})

      @instance.hostname = "newhostname"
      @instance.flush
    end
  end
end
