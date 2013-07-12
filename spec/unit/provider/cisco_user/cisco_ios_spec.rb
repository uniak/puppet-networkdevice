#! /usr/bin/env ruby
require 'spec_helper'

require 'puppet/provider/cisco_user/cisco_ios'

provider_class = Puppet::Type.type(:cisco_user).provider(:cisco_ios)

describe provider_class do
  before do
    @user = stub_everything 'user'
    @user.stubs(:name).returns('admin')
    @user.stubs(:params_to_hash)
    @users = [ @user ]

    @switch = stub_everything 'switch'
    @switch.stubs(:user).returns(@users)
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

    it "should delegate to the device user fetcher" do
      @device.expects(:switch).returns(@switch)
      @switch.expects(:user).with('admin').returns(@user)
      @user.expects(:params_to_hash)
      provider_class.lookup(@device, 'admin')
    end

    it "should return the given configuration data" do
      @device.expects(:switch).returns(@switch)
      @switch.expects(:user).with('admin').returns(@user)
      @user.expects(:params_to_hash).returns({ :privilege => 15 })
      provider_class.lookup(@device, 'admin').should == { :privilege => 15 }
    end
  end

  describe "when the configuration is being flushed" do
    it "should call the device configuration update method with current and past properties" do
      @instance = provider_class.new(@device, :ensure => :present, :name => 'admin', :privilege => 15)
      @instance.resource = @resource
      @resource.stubs(:[]).with(:name).returns('admin')
      @instance.stubs(:device).returns(@device)
      @switch.expects(:user).with('admin').returns(@user)
      @user.expects(:update).with({:ensure => :present, :name => 'admin', :privilege => 15},
                                  {:ensure => :present, :name => 'admin', :privilege => 10})
      @user.expects(:update).never

      @instance.privilege = 10
      @instance.flush
    end
  end
end
