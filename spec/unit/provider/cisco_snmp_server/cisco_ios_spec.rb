#! /usr/bin/env ruby
require 'spec_helper'
require 'puppet/provider/cisco_snmp_server/cisco_ios'

describe Puppet::Type.type(:cisco_snmp_server).provider(:cisco_ios) do
  before do
    @snmp = stub_everything 'snmp'
    @snmp.stubs(:name).returns(:running)
    @snmp.stubs(:params_to_hash)

    @switch = stub_everything 'switch'
    @switch.stubs(:params_to_hash).returns({})

    @device = stub_everything 'device'
    @device.stubs(:switch).returns(@switch)

    @resource = stub("resource", :name => :running)

    @provider = described_class.new(@device, @resource)
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

    it "should delegate to the device snmp fetcher" do
      @device.expects(:switch).returns(@switch)
      @switch.expects(:snmp).with(:running).returns(@snmp)
      described_class.lookup(@device, :running)
    end

    it "should return the given configuration data" do
      @device.expects(:switch).returns(@switch)
      @switch.expects(:snmp).with(:running).returns(@snmp)
      @snmp.expects(:params_to_hash).returns({:contact => 'foo@bar'})
      described_class.lookup(@device, :running).should == { :contact => 'foo@bar' }
    end
  end

  describe "when the configuration is being flushed" do
    it "should call the device configuration update method with current and past properties" do
      @instance = described_class.new(@device, :name => :running, :contact => 'foo@bar')
      @instance.contact = 'bar@foo'
      @instance.resource = @resource
      @resource.stubs(:[]).with(:name).returns(:running)
      @instance.stubs(:device).returns(@device)
      @switch.expects(:snmp).with(:running).returns(@snmp_host)
      @snmp_host.expects(:update).with({:name => :running, :contact => 'foo@bar'},
                                       {:name => :running, :contact => 'bar@foo'})

      @instance.flush
    end
  end
end
