#! /usr/bin/env ruby
require 'spec_helper'

require 'puppet/provider/cisco_line/cisco_ios'

provider_class = Puppet::Type.type(:cisco_line).provider(:cisco_ios)

describe provider_class do
  before do
    @line = stub_everything 'line network'
    @line.stubs(:name).returns('vty 10')
    @line.stubs(:params_to_hash)
    @lines = [ @line ]

    @switch = stub_everything 'switch'
    @switch.stubs(:lines).returns(@lines)
    @switch.stubs(:params_to_hash).returns({})

    @device = stub_everything 'device'
    @device.stubs(:switch).returns(@switch)

    @resource = stub("resource", :exec_timeout => 60)

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

    it "should delegate to the device line fetcher" do
      @device.expects(:switch).returns(@switch)
      @switch.expects(:line).with('vty 10').returns(@line)
      @line.expects(:params_to_hash)
      provider_class.lookup(@device, 'vty 10')
    end

    it "should return the given configuration data" do
      @device.expects(:switch).returns(@switch)
      @switch.expects(:line).with('vty 10').returns(@line)
      @line.expects(:params_to_hash).returns({:exec_timeout => 60 })
      provider_class.lookup(@device, 'vty 10').should == {:exec_timeout => 60 }
    end
  end

  describe "when the configuration is being flushed" do
    it "should call the device configuration update method with current and past properties" do
      @instance = provider_class.new(@device, :ensure => :present, :name => "vty 10", :exec_timeout => 60)
      @instance.resource = @resource
      @resource.stubs(:[]).with(:name).returns('vty 10')
      @instance.stubs(:device).returns(@device)
      @switch.expects(:line).with('vty 10').returns(@line)
      @line.expects(:update).with( {:ensure => :present, :name => "vty 10", :exec_timeout => 60 },
                                     {:ensure => :present, :name => "vty 10", :exec_timeout => 120 })
      @line.expects(:update).never

      @instance.exec_timeout = 120
      @instance.flush
    end
  end
end
