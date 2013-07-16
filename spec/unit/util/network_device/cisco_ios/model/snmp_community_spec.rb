#! /usr/bin/env ruby
require 'spec_helper'
require 'puppet/util/network_device'
require 'puppet/util/network_device/cisco_ios/model/snmp_community'

describe Puppet::Util::NetworkDevice::Cisco_ios::Model::Snmp_community do
  before(:each) do
    @transport = stub_everything 'transport'
    @snmp_community = described_class.new(@transport, {}, {:ensure => :present, :name => 'foobar'})
  end

  describe 'when working with snmp_community params' do
    before do
      @snmp_community_config = <<EOF
snmp-server community foobar view foo RO SNMP-ALLOW
snmp-server community foobar-rw RW SNMP-ALLOW
EOF
    end

    it 'should initialize various base params' do
      @snmp_community.params.should_not == be_empty
    end

    it 'should set the name from the options' do
      @snmp_community.name.should == 'foobar'
    end

    it 'should set the scope_name on the perm param' do
      @snmp_community.params[:perm].scope_name.should == 'foobar'
    end

    it 'should parse the perm param' do
      @transport.stubs(:command).with('sh run', {:cache => true, :noop => false}).returns(@snmp_community_config)
      @snmp_community.evaluate_new_params
      @snmp_community.params[:perm].value.should == :ro
    end

    it 'should parse the view param' do
      @transport.stubs(:command).with('sh run', {:cache => true, :noop => false}).returns(@snmp_community_config)
      @snmp_community.evaluate_new_params
      @snmp_community.params[:view].value.should == 'foo'
    end

    it 'should parse the acl param' do
      @transport.stubs(:command).with('sh run', {:cache => true, :noop => false}).returns(@snmp_community_config)
      @snmp_community.evaluate_new_params
      @snmp_community.params[:acl].value.should == 'SNMP-ALLOW'
    end

    it 'should update the value'do
      @transport.expects(:command).with('snmp-server community foobar rw')
      @transport.stubs(:command).with('sh run', {:cache => true, :noop => false}).returns(@snmp_community_config)
      @snmp_community.evaluate_new_params
      @snmp_community.update({:ensure => :present, :perm => :ro, :view => 'foo', :acl => 'SNMP-ALLOW'},
                             {:ensure => :present, :perm => :rw, :view => :absent, :acl => :absent})
    end

    it 'should remove the value' do
      @transport.expects(:command).with('no snmp-server community foobar view foo ro SNMP-ALLOW')
      @transport.stubs(:command).with('sh run', {:cache => true, :noop => false}).returns(@snmp_community_config)
      @snmp_community.evaluate_new_params
      @snmp_community.update({:ensure => :present}, {:ensure => :absent})
    end

    it 'should add the value' do
      @transport.expects(:command).with('snmp-server community foobar ro')
      @transport.stubs(:command).with('sh run', {:cache => true, :noop => false}).returns("")
      @snmp_community.evaluate_new_params
      @snmp_community.update({:ensure => :absent}, {:ensure => :present, :perm => :ro})
    end
  end
end
