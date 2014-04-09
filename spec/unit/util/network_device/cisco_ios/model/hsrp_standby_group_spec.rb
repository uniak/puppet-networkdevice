#! /usr/bin/env ruby
require 'spec_helper'
require 'puppet/util/network_device'
require 'puppet/util/network_device/cisco_ios/model/hsrp_standby_group'

describe Puppet::Util::NetworkDevice::Cisco_ios::Model::HsrpStandbyGroup do

  let(:parent_interface) { 'Vlan900' }
  let(:standby_group) { '1' }
  let(:the_name) { "#{parent_interface}/#{standby_group}" }
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
 standby 1 preempt
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
      group.parent_interface.should == parent_interface
      group.standby_group.should == standby_group
    end
    it 'should accept separate namevar specifications' do
      group = Puppet::Util::NetworkDevice::Cisco_ios::Model::HsrpStandbyGroup.new(transport, {}, { :parent_interface => parent_interface, :standby_group => standby_group })
      group.name.should == the_name
      group.parent_interface.should == parent_interface
      group.standby_group.should == standby_group
    end
    it 'should apply group overrides to a parsed title' do
      group = Puppet::Util::NetworkDevice::Cisco_ios::Model::HsrpStandbyGroup.new(transport, {}, { :name => the_name, :standby_group => '4' })
      group.name.should == "#{parent_interface}/4"
      group.parent_interface.should == parent_interface
      group.standby_group.should == '4'
    end
    it 'should apply interface overrides to a parsed title' do
      group = Puppet::Util::NetworkDevice::Cisco_ios::Model::HsrpStandbyGroup.new(transport, {}, { :name => the_name, :parent_interface => 'Vlan888' })
      group.name.should == "Vlan888/#{standby_group}"
      group.parent_interface.should == 'Vlan888'
      group.standby_group.should == standby_group
    end
  end

  describe 'when working with hsrp_standby_group params' do
    before(:each) do
      @hsrp_standby_group = Puppet::Util::NetworkDevice::Cisco_ios::Model::HsrpStandbyGroup.new(transport, {}, {
          :parent_interface => parent_interface,
          :standby_group => standby_group
          })
    end

    it 'should initialize various base params' do
      @hsrp_standby_group.params.should_not == be_empty
    end

    it 'should set the name from the options' do
      @hsrp_standby_group.name.should == the_name
    end

    it 'should set the parent_interface from the options' do
      @hsrp_standby_group.parent_interface.should == parent_interface
    end

    it 'should set the group from the options' do
      @hsrp_standby_group.standby_group.should == standby_group
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

      it 'should find the preempt param' do
        @hsrp_standby_group.params[:preempt].value.should == :present
      end

      it 'should find the preempt delay minimum param' do
        @hsrp_standby_group.params[:preempt_delay_minimum].value.should == '60'
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

