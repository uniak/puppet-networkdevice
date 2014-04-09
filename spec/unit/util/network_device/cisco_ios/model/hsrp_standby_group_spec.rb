#! /usr/bin/env ruby
require 'spec_helper'
require 'puppet/util/network_device'
require 'puppet/util/network_device/cisco_ios/model/hsrp_standby_group'

describe Puppet::Util::NetworkDevice::Cisco_ios::Model::HsrpStandbyGroup do

  let(:interface_name) { 'Vlan900' }
  let(:standby_group) { '1' }
  let(:the_name) { "#{interface_name}/#{standby_group}" }
  let(:transport) { stub "transport" }
  let(:interface_config) do
    result = <<END
interface Vlan900
 description TEST_VLAN900
 ip vrf forwarding TEST_VRF
 ip address 10.16.18.97 255.255.255.224
 ip helper-address 1.1.2.2
 no ip redirects
 no ip unreachables
 ip flow ingress
 standby delay reload 120
 standby 1 ip 10.x.x.x
 standby 1 timers msec 250 msec 750
 standby 1 authentication abcdefgh12345
 standby 1 priority 200
 standby 1 preempt delay minimum 60
 standby 1 track TenGigabitEthernet5/1 30
 standby 1 track TenGigabitEthernet5/2 30
!
END
  end

  describe 'when initialising' do
    it 'should accept and parse a single title' do
      group = Puppet::Util::NetworkDevice::Cisco_ios::Model::HsrpStandbyGroup.new(transport, {}, { :name => the_name })
      group.name.should == the_name
      group.if_name.should == interface_name
      group.group.should == standby_group
    end
    it 'should accept separate namevar specifications' do
      group = Puppet::Util::NetworkDevice::Cisco_ios::Model::HsrpStandbyGroup.new(transport, {}, { :if_name => interface_name, :group => standby_group })
      group.name.should == the_name
      group.if_name.should == interface_name
      group.group.should == standby_group
    end
    it 'should apply group overrides to a parsed title' do
      group = Puppet::Util::NetworkDevice::Cisco_ios::Model::HsrpStandbyGroup.new(transport, {}, { :name => the_name, :group => '4' })
      group.name.should == "#{interface_name}/4"
      group.if_name.should == interface_name
      group.group.should == '4'
    end
    it 'should apply interface overrides to a parsed title' do
      group = Puppet::Util::NetworkDevice::Cisco_ios::Model::HsrpStandbyGroup.new(transport, {}, { :name => the_name, :if_name => 'Vlan888' })
      group.name.should == "Vlan888/#{standby_group}"
      group.if_name.should == 'Vlan888'
      group.group.should == standby_group
    end
  end

  describe 'when working with hsrp_standby_group params' do
    before(:each) do
      @hsrp_standby_group = Puppet::Util::NetworkDevice::Cisco_ios::Model::HsrpStandbyGroup.new(transport, {}, {
          :if_name => interface_name,
          :group => standby_group
          })
    end

    it 'should initialize various base params' do
      @hsrp_standby_group.params.should_not == be_empty
    end

    it 'should set the name from the options' do
      @hsrp_standby_group.name.should == the_name
    end

    it 'should set the if_name from the options' do
      @hsrp_standby_group.if_name.should == interface_name
    end

    it 'should set the group from the options' do
      @hsrp_standby_group.group.should == standby_group
    end

    it 'should set the scope_name on the authentication param' do
      @hsrp_standby_group.params[:authentication].scope_name.should == the_name
    end

    describe "parsing the configuration" do
      before(:each) do
        transport.expects(:command).with('sh run', {:cache => true, :noop => false}).returns(interface_config).at_least(1)
        @hsrp_standby_group.evaluate_new_params
      end

      it 'should find the authentication param' do
        @hsrp_standby_group.params[:authentication].value.should == 'abcdefgh12345'
      end
    end
    
    describe "configuring the device" do
      before(:each) do
        transport.expects(:command).with('sh run', {:cache => true, :noop => false}).returns(interface_config).at_least(1)
        @hsrp_standby_group.evaluate_new_params
      end

      it 'should find the authentication param' do
        transport.expects(:command).with('conf t', anything)
        transport.expects(:command).with('interface Vlan900', anything)
        transport.expects(:command).with('standby 1 authentication 1234', anything)
        transport.stubs(:command).with('exit', anything)
        transport.stubs(:command).with('end', anything)
        @hsrp_standby_group.update({}, {:authentication => '1234'})
      end
    end
  end
end

