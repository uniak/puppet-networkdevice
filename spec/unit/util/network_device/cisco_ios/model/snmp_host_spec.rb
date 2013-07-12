#! /usr/bin/env ruby
require 'spec_helper'
require 'puppet/util/network_device'
require 'puppet/util/network_device/cisco_ios/model/snmp_host'

describe Puppet::Util::NetworkDevice::Cisco_ios::Model::SnmpHost do
  before(:each) do
    @transport = stub_everything 'transport'
    @snmp_host = described_class.new(@transport, {}, {:ensure => :present, :name => '127.0.0.1'})
  end

  describe 'when working with snmp_host params' do
    before do
      @snmp_host_config = <<EOF
snmp-server host 127.0.0.1 foobar udp-port 3000
EOF
    end

    it 'should initialize various base params' do
      @snmp_host.params.should_not == be_empty
    end

    it 'should set the name from the options' do
      @snmp_host.name.should == '127.0.0.1'
    end

    it 'should set the scope_name on the community param' do
      @snmp_host.params[:community].scope_name.should == '127.0.0.1'
    end

    it 'should parse the community param' do
      @transport.stubs(:command).with('sh run', {:cache => true, :noop => false}).returns(@snmp_host_config)
      @snmp_host.evaluate_new_params
      @snmp_host.params[:community].value.should == 'foobar'
    end

    it 'should parse the udp_port param' do
      @transport.stubs(:command).with('sh run', {:cache => true, :noop => false}).returns(@snmp_host_config)
      @snmp_host.evaluate_new_params
      @snmp_host.params[:udp_port].value.should == '3000'
    end

    it 'should update the value' do
      @transport.expects(:command).with('no snmp-server host 127.0.0.1 foobar udp-port 3000')
      @transport.expects(:command).with('snmp-server host 127.0.0.1 foo')
      @transport.stubs(:command).with('sh run', {:cache => true, :noop => false}).returns(@snmp_host_config)
      @snmp_host.evaluate_new_params
      @snmp_host.update({:ensure => :present, :community => 'foo', :udp_port => 3000},
                        {:ensure => :present, :community => 'foo', :udp_port => :absent})
    end

    it 'should remove the value' do
      @transport.expects(:command).with('no snmp-server host 127.0.0.1 foobar udp-port 3000')
      @transport.stubs(:command).with('sh run', {:cache => true, :noop => false}).returns(@snmp_host_config)
      @snmp_host.evaluate_new_params
      @snmp_host.update({:ensure => :present, :community => 'foo', :udp_port => 3000},
                        {:ensure => :absent})
    end

    it 'should add the value' do
      @transport.expects(:command).with('snmp-server host 127.0.0.1 foobar udp-port 3000')
      @transport.stubs(:command).with('sh run', {:cache => true, :noop => false}).returns("")
      @snmp_host.evaluate_new_params
      @snmp_host.update({:ensure => :absent}, {:ensure => :present, :community => 'foobar', :udp_port => 3000})
    end
  end
end
