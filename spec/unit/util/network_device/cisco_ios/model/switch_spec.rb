#! /usr/bin/env ruby
require 'spec_helper'
require 'puppet/util/network_device'
require 'puppet/util/network_device/cisco_ios/model/switch'

describe Puppet::Util::NetworkDevice::Cisco_ios::Model::Switch do
  before(:each) do
    @transport = stub_everything "transport"
    @switch = Puppet::Util::NetworkDevice::Cisco_ios::Model::Switch.new(@transport, {})
  end

  describe 'when working with switch params' do
    it 'should initialize various base params' do
      @switch.params.should_not == be_empty
    end

    it 'should parse the hostname param' do
      @transport.stubs(:command).with('sh run', anything).returns('hostname test0r')
      @switch.evaluate_new_params
      @switch.params[:hostname].value.should == 'test0r'
    end

    it 'should enter configuration mode' do
      @transport.expects(:command).with('conf t', anything).once
      @switch.evaluate_new_params
      @switch.update({:hostname => 'test0r'}, {:hostname => 'test2'})
    end

    it 'should update the value' do
      @transport.expects(:command).with('hostname test2', anything)
      @transport.stubs(:command).with('sh run', anything).returns('hostname test0r')
      @switch.evaluate_new_params
      @switch.update({:hostname => 'test0r'}, {:hostname => 'test2'})
    end

    it 'should remove the value' do
      @transport.expects(:command).with('no hostname test0r')
      @transport.stubs(:command).with('sh run', anything).returns('hostname test0r')
      @switch.evaluate_new_params
      @switch.update({:hostname => 'test0r'}, {:hostname => :absent})
    end

    it 'should add the value' do
      @transport.expects(:command).with('hostname test2')
      @transport.stubs(:command).with('sh run', anything).returns('')
      @switch.evaluate_new_params
      @switch.update({}, {:hostname => 'test2'})
    end

    it 'should properly treat arrays' do
      @transport.expects(:command).with('no ntp server 127.0.0.1')
      @transport.expects(:command).with('ntp server 127.0.0.3')
      @switch.evaluate_new_params
      @switch.update({:ntp_servers => ['127.0.0.1', '127.0.0.2']}, {:ntp_servers => ['127.0.0.2', '127.0.0.3']})
    end

    it 'it should respect device facts' do
      @switch = Puppet::Util::NetworkDevice::Cisco_ios::Model::Switch.new(@transport, {'canonicalized_hardwaremodel' => 'c4500'})
      @transport.expects(:command).with('system mtu 1500')
      @switch.evaluate_new_params
      @switch.update({}, {:system_mtu_routing => '1500'})
    end
  end
end
