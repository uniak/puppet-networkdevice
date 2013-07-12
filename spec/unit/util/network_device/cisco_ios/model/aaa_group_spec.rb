#! /usr/bin/env ruby
require 'spec_helper'
require 'puppet/util/network_device'
require 'puppet/util/network_device/cisco_ios/model/aaa_group'

describe Puppet::Util::NetworkDevice::Cisco_ios::Model::Aaa_group do
  before(:each) do
    @transport = stub_everything "transport"
    @aaa_group = Puppet::Util::NetworkDevice::Cisco_ios::Model::Aaa_group.new(@transport, {}, { :name => 'NETWORK', :ensure => :present })
  end

  describe 'when working with aaa_group params' do
    before do
      @aaa_group_config = <<END
aaa new-model
!
!
aaa group server radius NETWORK
 server 10.1.100.6 auth-port 1812 acct-port 1813
!
aaa group server radius TEST
 server test.example.com auth-port 2000 acct-port 2002
!
aaa authentication login default group NETWORK local
aaa authorization exec default group NETWORK local 
!
END
    end

    it 'should initialize various base params' do
      @aaa_group.params.should_not == be_empty
    end

    it 'should set the name from the options' do
      @aaa_group.name.should == 'NETWORK'
    end

    it 'should set the scope_name on the server param' do
      @aaa_group.params[:server].scope_name.should == 'NETWORK'
    end

    it 'should parse the server param' do
      @transport.stubs(:command).with('sh run', {:cache => true, :noop => false}).returns(@aaa_group_config)
      @aaa_group.evaluate_new_params
      @aaa_group.params[:server].value.should == '10.1.100.6'
    end

    it 'should parse the acct-port param' do
      @transport.stubs(:command).with('sh run', {:cache => true, :noop => false}).returns(@aaa_group_config)
      @aaa_group.evaluate_new_params
      @aaa_group.params[:acct_port].value.should == "1813"
    end

    it 'should parse the auth-port param' do
      @transport.stubs(:command).with('sh run', {:cache => true, :noop => false}).returns(@aaa_group_config)
      @aaa_group.evaluate_new_params
      @aaa_group.params[:auth_port].value.should == "1812"
    end

    it 'should parse the local authentication param' do
      @transport.stubs(:command).with('sh run', {:cache => true, :noop => false}).returns(@aaa_group_config)
      @aaa_group.evaluate_new_params
      @aaa_group.params[:local_authentication].value.should == :true
    end

    it 'should parse the local authorization param' do
      @transport.stubs(:command).with('sh run', {:cache => true, :noop => false}).returns(@aaa_group_config)
      @aaa_group.evaluate_new_params
      @aaa_group.params[:local_authorization].value.should == :true
    end

    it 'should not enter aaa group configuration mode if nothings changed' do
      @transport.expects(:command).with('aaa group server radius NETWORK', {:cache => true, :noop => false}).never
      @aaa_group.evaluate_new_params
      @aaa_group.update()
    end

    it 'should update the value' do
      @transport.expects(:command).with('server 1.1.1.1 auth-port 1812 acct-port 1813')
      @transport.stubs(:command).with('sh run', {:cache => true, :noop => false}).returns(@aaa_group_config)
      @aaa_group.evaluate_new_params
      @aaa_group.update({:ensure => :present, :server => '10.1.100.6'}, {:ensure => :present, :server => '1.1.1.1'})
    end

    it 'should remove the value' do
      @transport.expects(:command).with('no aaa group server radius NETWORK').once
      @transport.stubs(:command).with('sh run', {:cache => true, :noop => false}).returns(@aaa_group_config)
      @aaa_group.evaluate_new_params
      @aaa_group.update({:ensure => :present, :name => 'NETWORK', :protocol => :radius}, {:ensure => :absent})
    end

    it 'should add the value' do
      @transport.expects(:command).with('server 10.1.100.60')
      @transport.stubs(:command).with("sh run", {:cache => true, :noop => false}).returns("aaa group server radius NETWORK\n!")
      @aaa_group.evaluate_new_params
      @aaa_group.update({:ensure => :absent}, {:ensure => :present, :server => '10.1.100.60'})
    end

    it 'should set the authentication group' do
      @transport.expects(:command).with('aaa authentication login default group NETWORK local')
      @transport.stubs(:command).with("sh run", {:cache => true, :noop => false}).returns("aaa group server radius NETWORK\nserver 10.1.100.6 auth-port 1812 acct-port 1813\n!")
      @aaa_group.evaluate_new_params
      before = {:ensure => :present, :server => '10.1.100.6', :auth_port => 1812, :acct_port => 1813, :local_authentication => false}
      after = before.dup
      after[:local_authentication] = true
      @aaa_group.update(before,after)
    end

    it 'should set the authorization group' do
      @transport.expects(:command).with('aaa authorization exec default group NETWORK local')
      @transport.stubs(:command).with("sh run", {:cache => true, :noop => false}).returns("aaa group server radius NETWORK\nserver 10.1.100.6 auth-port 1812 acct-port 1813\n!")
      @aaa_group.evaluate_new_params
      before = {:ensure => :present, :server => '10.1.100.6', :auth_port => 1812, :acct_port => 1813, :local_authorization => false}
      after = before.dup
      after[:local_authorization] = true
      @aaa_group.update(before,after)
    end
  end
end
