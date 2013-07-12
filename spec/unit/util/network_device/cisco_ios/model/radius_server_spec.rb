#! /usr/bin/env ruby
require 'spec_helper'
require 'puppet/util/network_device'
require 'puppet/util/network_device/cisco_ios/model/radius_server'

describe Puppet::Util::NetworkDevice::Cisco_ios::Model::RadiusServer do
  before(:each) do
    @transport = stub_everything "transport"
    @rad = Puppet::Util::NetworkDevice::Cisco_ios::Model::RadiusServer.new(@transport, {}, { :name => '127.0.0.1', :ensure => :present })
  end

  describe 'when working with radius_server params' do
    before do
      @radius_server_config = <<EOF
radius-server host 127.0.0.1 auth-port 1812 acct-port 1813 key 7 123456789A123
EOF
    end

    it 'should initialize various base params' do
      @rad.params.should_not == be_empty
    end

    it 'should set the name from the options' do
      @rad.name.should == '127.0.0.1'
    end

    it 'should set the scope_name' do
      @rad.params[:auth_port].scope_name.should == '127.0.0.1'
    end

    { :acct_port => '1813', :auth_port => '1812', :key_type => '7', :key => '123456789A123' }.each do |prop, val|
      it "should parse the #{prop} param" do
        @transport.stubs(:command).with('sh run', {:cache => true, :noop => false}).returns(@radius_server_config)
        @rad.evaluate_new_params
        @rad.params[prop].value.should == val
      end
    end

    it 'should update the value' do
      @transport.expects(:command).with('no radius-server host 127.0.0.1 acct-port 1813 auth-port 1812 key 7 123456789A123')
      @transport.expects(:command).with('radius-server host 127.0.0.1 acct-port 1813 auth-port 1812 key 7 foobar')
      @transport.stubs(:command).with('sh run', {:cache => true, :noop => false}).returns(@radius_server_config)
      @rad.evaluate_new_params
      @rad.update({:ensure => :present, :key_type => 7, :key => '123456789A123'},
                  {:ensure => :present, :key_type => 7, :key => 'foobar'})
    end

    it 'should remove the value' do
      @transport.expects(:command).with('no radius-server host 127.0.0.1 acct-port 1813 auth-port 1812 key 7 123456789A123')
      @transport.stubs(:command).with('sh run', {:cache => true, :noop => false}).returns(@radius_server_config)
      @rad.evaluate_new_params
      @rad.update({:ensure => :present, :key_type => 7, :key => '123456789A123', :auth_port => 1812},
                  {:ensure => :absent})
    end

    it 'should add the value' do
      @transport.expects(:command).with('radius-server host 127.0.0.1 acct-port 1813 auth-port 1812 key 7 foobar')
      @transport.stubs(:command).with('sh run', {:cache => true, :noop => false}).returns('')
      @rad.evaluate_new_params
      @rad.update({:ensure => :absent},
                  {:ensure => :present, :acct_port => 1813, :auth_port => 1812, :key_type => 7, :key => 'foobar'})
    end
  end
end
