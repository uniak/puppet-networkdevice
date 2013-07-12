#! /usr/bin/env ruby
require 'spec_helper'
require 'puppet/util/network_device'
require 'puppet/util/network_device/cisco_ios/model/acl'

describe Puppet::Util::NetworkDevice::Cisco_ios::Model::Acl do
  before(:each) do
    @transport = stub_everything "transport"
    @acl = Puppet::Util::NetworkDevice::Cisco_ios::Model::Acl.new(@transport, {}, { :name => 'SSHCLIENTS', :ensure => :present })
  end

  describe 'when working with acl params' do
    before do
      @acl_config = <<END
!
ip access-list standard SNMPSERVERS
 permit 10.100.0.0 0.0.255.255
ip access-list extended TEST-EX
 permit 66.0.0.0 0.255.255.255
 deny 66.100.0.0 0.0.255.255
ip access-list standard SSHCLIENTS
 permit 10.0.0.0 0.255.255.255
 deny 10.100.0.0 0.0.255.255
!
END
    end

    it 'should initialize various base params' do
      @acl.params.should_not == be_empty
    end

    it 'should set the name from the options' do
      @acl.name.should == 'SSHCLIENTS'
    end

    it 'should set the scope_name on the type param' do
      @acl.params[:type].scope_name.should == 'SSHCLIENTS'
    end

    it 'should parse the type param' do
      @transport.stubs(:command).with('sh run', {:cache => true, :noop => false}).returns(@acl_config)
      @acl.evaluate_new_params
      @acl.params[:type].value.should == 'standard'
    end

    it 'should parse the ACL' do
      @transport.stubs(:command).with('sh run', {:cache => true, :noop => false}).returns(@acl_config)
      @acl.evaluate_new_params
      @acl.params[:acl].value.should == ['permit 10.0.0.0 0.255.255.255', 'deny 10.100.0.0 0.0.255.255']
    end

    it 'should not enter acl configuration mode if nothing changed' do
      @transport.expects(:command).with('ip access-list standard SSHCLIENTS', {:cache => true, :noop => false}).never
      @acl.evaluate_new_params
      @acl.update()
    end

    it 'should update the acl' do
      @transport.expects(:command).with('ip access-list standard SSHCLIENTS', anything)
      @transport.expects(:command).with('no deny 10.100.0.0 0.0.255.255')
      @transport.expects(:command).with('deny 66.66.0.0 0.0.255.255')
      @transport.expects(:command).with('exit')
      @transport.stubs(:command).with('sh run', {:cache => true, :noop => false}).returns(@acl_config)
      @acl.evaluate_new_params

      @acl.update( { :ensure => :present, :type => 'standard', :acl => [ 'permit 10.0.0.0 0.255.255.255', 'deny 10.100.0.0 0.0.255.255']}, { :ensure => :present, :type => 'standard', :acl => [ 'permit 10.0.0.0 0.255.255.255', 'deny 66.66.0.0 0.0.255.255']})
    end

    it 'should remove the ACL completely' do
      @transport.expects(:command).with('no ip access-list standard SSHCLIENTS').once
      @transport.stubs(:command).with('sh run', {:cache => true, :noop => false}).returns(@acl_config)
      @acl.evaluate_new_params
      @acl.update({:ensure => :present, :name => 'SSHCLIENTS', :type => :standard}, {:ensure => :absent, :name => 'SSHCLIENTS'})
    end

    it 'should add to the ACL' do
      @transport.expects(:command).with('permit 10.1.100.60 0.0.0.0')
      @transport.stubs(:command).with("sh run", {:cache => true, :noop => false}).returns("ip access-list standard TEST\n!")
      @acl.evaluate_new_params
      @acl.update(
        {:ensure => :present, :type => 'standard', :acl => []},
        {:ensure => :present, :type => 'standard', :acl => ['permit 10.1.100.60 0.0.0.0']})
    end
  end
end
