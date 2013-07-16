#! /usr/bin/env ruby
require 'spec_helper'
require 'puppet/provider/cisco_snmp_server_community/cisco_ios'

describe Puppet::Type.type(:cisco_snmp_server_community).provider(:cisco_ios) do
  before do
    @snmp_community = stub_everything 'snmp_community foobar'
    @snmp_community.stubs(:name).returns('foobar')
    @snmp_community.stubs(:params_to_hash)

    @switch = stub_everything 'switch'
    @switch.stubs(:params_to_hash).returns({})

    @device = stub_everything 'device'
    @device.stubs(:switch).returns(@switch)

    @resource = stub("resource", :perm => :rw)

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

    it "should delegate to the device snmp_community fetcher" do
      @device.expects(:switch).returns(@switch)
      @switch.expects(:snmp_community).with('foobar').returns(@snmp_community)
      described_class.lookup(@device, 'foobar')
    end

    it "should return the given configuration data" do
      @device.expects(:switch).returns(@switch)
      @switch.expects(:snmp_community).with('foobar').returns(@snmp_community)
      @snmp_community.expects(:params_to_hash).returns({:perm => :ro})
      described_class.lookup(@device, 'foobar').should == { :perm => :ro }
    end
  end

  describe "when the configuration is being flushed" do
    it "should call the device configuration update method with current and past properties" do
      @instance = described_class.new(@device, :ensure => :present, :name => 'foobar', :perm => :ro)
      @instance.perm = :rw
      @instance.resource = @resource
      @resource.stubs(:[]).with(:name).returns('foobar')
      @instance.stubs(:device).returns(@device)
      @switch.expects(:snmp_community).with('foobar').returns(@snmp_community)
      @snmp_community.expects(:update).with({:ensure => :present, :name => 'foobar', :perm => :ro},
                                            {:ensure => :present, :name => 'foobar', :perm => :rw})

      @instance.flush
    end
  end
end
