#! /usr/bin/env ruby
require 'spec_helper'
require 'puppet/provider/cisco_snmp_server_host/cisco_ios'

describe Puppet::Type.type(:cisco_snmp_server_host).provider(:cisco_ios) do
  before do
    @snmp_host = stub_everything 'snmp_host foobar'
    @snmp_host.stubs(:name).returns('127.0.0.1')
    @snmp_host.stubs(:params_to_hash)

    @switch = stub_everything 'switch'
    @switch.stubs(:params_to_hash).returns({})

    @device = stub_everything 'device'
    @device.stubs(:switch).returns(@switch)

    @resource = stub("resource", :community => 'foo')

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

    it "should delegate to the device snmp_host fetcher" do
      @device.expects(:switch).returns(@switch)
      @switch.expects(:snmp_host).with('127.0.0.1').returns(@snmp_host)
      described_class.lookup(@device, '127.0.0.1')
    end

    it "should return the given configuration data" do
      @device.expects(:switch).returns(@switch)
      @switch.expects(:snmp_host).with('127.0.0.1').returns(@snmp_host)
      @snmp_host.expects(:params_to_hash).returns({:perm => :ro})
      described_class.lookup(@device, '127.0.0.1').should == { :perm => :ro }
    end
  end

  describe "when the configuration is being flushed" do
    it "should call the device configuration update method with current and past properties" do
      @instance = described_class.new(@device, :ensure => :present, :name => '127.0.0.1', :community => 'foo')
      @instance.community = 'bar'
      @instance.resource = @resource
      @resource.stubs(:[]).with(:name).returns('127.0.0.1')
      @instance.stubs(:device).returns(@device)
      @switch.expects(:snmp_host).with('127.0.0.1').returns(@snmp_host)
      @snmp_host.expects(:update).with({:ensure => :present, :name => '127.0.0.1', :community => 'foo'},
                                            {:ensure => :present, :name => '127.0.0.1', :community => 'bar'})

      @instance.flush
    end
  end
end
