#! /usr/bin/env ruby
require 'spec_helper'

require 'puppet/provider/cisco_hsrp_standby_group/cisco_ios'

provider_class = Puppet::Type.type(:cisco_hsrp_standby_group).provider(:cisco_ios)

describe provider_class do
  let(:interface_name) { 'Vlan900' }
  let(:standby_group) { '1' }
  let(:the_name) { "#{interface_name}/#{standby_group}" }

  before do
    @hsrp_standby_group = stub_everything "hsrp #{the_name}"
    @hsrp_standby_group.stubs(:name).returns(the_name)
    @hsrp_standby_group.stubs(:if_name).returns(interface_name)
    @hsrp_standby_group.stubs(:group).returns(standby_group)
    @hsrp_standby_group.stubs(:params_to_hash)
    @hsrp_standby_groups = [ @hsrp_standby_group ]

    @switch = stub_everything 'switch'
    @switch.stubs(:hsrp_standby_groups).returns(@hsrp_standby_groups)
    @switch.stubs(:params_to_hash).returns({})

    @device = stub_everything 'device'
    @device.stubs(:switch).returns(@switch)

    @resource = stub("resource", :authentication => "abcde12345")

    @provider = provider_class.new(@device, @resource)
  end

  it "should have a parent of Puppet::Provider::Cisco_ios" do
    provider_class.should < Puppet::Provider::Cisco_ios
  end

  it "should have an instances method" do
    provider_class.should respond_to(:instances)
  end

  it "should have an prefetch method" do
    provider_class.should respond_to(:prefetch)
  end

  describe "when looking up instances at prefetch" do
    before do
      provider_class.stubs(:device).yields(@device)
    end

    it "should delegate to the device interface fetcher" do
      @device.expects(:switch).returns(@switch)
      @switch.expects(:hsrp_standby_group).with(the_name).returns(@hsrp_standby_group)
      @hsrp_standby_group.expects(:params_to_hash)
      provider_class.lookup(@device, the_name)
    end

    it "should return the given configuration data" do
      @device.expects(:switch).returns(@switch)
      @switch.expects(:hsrp_standby_group).with(the_name).returns(@hsrp_standby_group)
      @hsrp_standby_group.expects(:params_to_hash).returns({ :authentication => "abcd4321" })
      provider_class.lookup(@device, the_name).should == { :authentication => "abcd4321" }
    end
  end

  describe "when the configuration is being flushed" do
    it "should call the device configuration update method with current and past properties" do
      @instance = provider_class.new(@device, :ensure => :present, :name => the_name, :authentication => "abcd4321")
      @instance.device.expects(:switch).returns(@switch)
      @switch.expects(:hsrp_standby_group).with(the_name).returns(@hsrp_standby_group)
      @hsrp_standby_group.expects(:update).with({:ensure => :present, :name => the_name, :authentication => "abcd4321"},
                                       {:ensure => :present, :name => the_name, :authentication => "xyz"})

      @instance.authentication = "xyz"
      @instance.flush
    end
  end
end
