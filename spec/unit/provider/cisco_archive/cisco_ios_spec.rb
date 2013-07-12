#! /usr/bin/env ruby
require 'spec_helper'
require 'puppet/provider/cisco_archive/cisco_ios'

provider_class = Puppet::Type.type(:cisco_archive).provider(:cisco_ios)

describe provider_class do
  before do
    @archive = stub_everything 'archive'
    @archive.stubs(:name).returns('running')
    @archive.stubs(:params_to_hash)
    @archives = [ @archive ]

    @switch = stub_everything 'switch'
    @switch.stubs(:archive).returns(@archives)
    @switch.stubs(:params_to_hash).returns({})

    @device = stub_everything 'device'
    @device.stubs(:switch).returns(@switch)

    @resource = stub('resource', :privilege => 15)

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

    it "should delegate to the device archive fetcher" do
      @device.expects(:switch).returns(@switch)
      @switch.expects(:archive).with('running').returns(@archive)
      @archive.expects(:params_to_hash)
      provider_class.lookup(@device, 'running')
    end

    it "should return the given configuration data" do
      @device.expects(:switch).returns(@switch)
      @switch.expects(:archive).with('running').returns(@archive)
      @archive.expects(:params_to_hash).returns({ :path => 'foobar' })
      provider_class.lookup(@device, 'running').should == { :path => 'foobar' }
    end
  end

  describe "when the configuration is being flushed" do
    it "should call the device configuration update method with current and past properties" do
      @instance = provider_class.new(@device, :name => 'running', :write_memory => :present)
      @instance.resource = @resource
      @resource.stubs(:[]).with(:name).returns('running')
      @instance.stubs(:device).returns(@device)
      @switch.expects(:archive).with('running').returns(@archive)
      @archive.expects(:update).with({:name => 'running', :write_memory => :present},
                                     {:name => 'running', :write_memory => :absent})
      @archive.expects(:update).never

      @instance.write_memory = :absent
      @instance.flush
    end
  end
end
