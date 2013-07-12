#! /usr/bin/env ruby
require 'spec_helper'
require 'puppet/util/network_device'
require 'puppet/util/network_device/cisco_ios/model/user'

describe Puppet::Util::NetworkDevice::Cisco_ios::Model::User do
  before(:each) do
    @transport = stub_everything "transport"
    @user = Puppet::Util::NetworkDevice::Cisco_ios::Model::User.new(@transport, {}, { :name => 'admin', :ensure => :present })
  end

  describe 'when working with user params' do
    before do
      @user_config = 'username admin privilege 15 password 7 0126085331281E8'
    end

    it 'should initialize various base params' do
      @user.params.should_not == be_empty
    end

    it 'should set the name from the options' do
      @user.name.should == 'admin'
    end

    it 'should set the scope_name' do
      @user.params[:privilege].scope_name.should == 'admin'
    end

    { :privilege => '15', :password_type => '7', :password => '0126085331281E8' }.each do |prop, val|
      it "should parse the #{prop} param" do
        @transport.stubs(:command).with('sh run', {:cache => true, :noop => false}).returns(@user_config)
        @user.evaluate_new_params
        @user.params[prop].value.should == val
      end
    end

    it 'should update the value' do
      @transport.expects(:command).with('username admin privilege 10 password 7 0126085331281E8')
      @transport.stubs(:command).with('sh run', {:cache => true, :noop => false}).returns(@user_config)
      @user.evaluate_new_params
      @user.update({:ensure => :present, :privilege => 15, :password_type => 7, :password => '0126085331281E8'},
                   {:ensure => :present, :privilege => 10, :password_type => 7, :password => '0126085331281E8'})
    end

    it 'should remove the value' do
      @transport.expects(:command).with('no username admin privilege 15 password 7 0126085331281E8')
      @transport.stubs(:command).with('sh run', {:cache => true, :noop => false}).returns(@user_config)
      @user.evaluate_new_params
      @user.update({:ensure => :present, :privilege => 15, :password_type => 7, :password => '0126085331281E8'},
                   {:ensure => :absent})
    end

    it 'should add the value' do
      @transport.expects(:command).with('username admin privilege 15 password 7 0126085331281E8')
      @transport.stubs(:command).with('sh run', {:cache => true, :noop => false}).returns(@user_config)
      @user.evaluate_new_params
      @user.update({:ensure => :absent},
                   {:ensure => :present, :privilege => 15, :password_type => 7, :password => '0126085331281E8'})
    end
  end
end
