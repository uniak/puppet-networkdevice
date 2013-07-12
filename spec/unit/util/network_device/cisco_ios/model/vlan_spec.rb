#! /usr/bin/env ruby
require 'spec_helper'
require 'puppet/util/network_device'
require 'puppet/util/network_device/cisco_ios/model/vlan'

describe Puppet::Util::NetworkDevice::Cisco_ios::Model::Vlan do
  before(:each) do
    @transport = stub_everything "transport"
    @vlan = Puppet::Util::NetworkDevice::Cisco_ios::Model::Vlan.new(@transport, {}, { :name => '1105', :ensure => :present })
  end

  describe 'when working with vlan params' do
    before do
      @vlan_config = <<END

VLAN Name                             Status    Ports
---- -------------------------------- --------- -------------------------------
1    default                          active    
666  UNUSED-PORTS                     active    Gi1/0/18
1002 fddi-default                     act/unsup 
1003 trcrf-default                    act/unsup 
1004 fddinet-default                  act/unsup 
1005 trbrf-default                    act/unsup 
1100 MGMT-NETWORK                     active    
1101 MGMT-SERVER                      active    
1102 TELEFONIE                        active    Gi1/0/3, Gi1/0/10, Gi1/0/14, Gi1/0/20, Gi1/0/22
1104 STORAGE                          active    
1105 SERVER-INTERN                    active    Gi1/0/2
1106 SERVER-EXTERN                    active    
1108 ADSL-LINKNETZ                    active    
1109 DRUCKER                          active    Gi1/0/8
1120 STUDENTEN                        active    Gi1/0/16
1128 MA-VERWALTUNG                    active    Gi1/0/4, Gi1/0/5, Gi1/0/6, Gi1/0/7, Gi1/0/9, Gi1/0/11, Gi1/0/12, Gi1/0/13, Gi1/0/15, Gi1/0/17
1132 VLAN1132                         active    
1136 SSID_ak-net                      active    
1140 SSID_1                           active    
1144 VLAN1144                         active    
1148 VLAN1148                         active    
END
  end

    it 'should initialize various base params' do
      @vlan.params.should_not == be_empty
    end

    it 'should set the name from the options' do
      @vlan.name.should == '1105'
    end

    it 'should set the scope_name on the desc param' do
      @vlan.params[:desc].scope_name.should == '1105'
    end

    it 'should parse description of the desc param' do
      @transport.stubs(:command).with('sh vlan brief', {:cache => true, :noop => false}).returns(@vlan_config)
      @vlan.evaluate_new_params
      @vlan.params[:desc].value.should == "SERVER-INTERN"
    end

    it 'should add a vlan with default description' do
      @transport.expects(:command).with('vlan 1150', :prompt => /\(config-vlan\)#\s?\z/n)
      @transport.expects(:command).with('exit')
      @transport.stubs(:command).with("sh vlan brief", {:cache => true, :noop => false}).returns(@vlan_config)
      @vlan = Puppet::Util::NetworkDevice::Cisco_ios::Model::Vlan.new(@transport, {}, { :name => '1150', :ensure => :present })
      @vlan.evaluate_new_params
      @vlan.update({:ensure => :absent}, {:ensure => :present})
    end

    it 'should update a vlan description' do
      @transport.expects(:command).with('vlan 1105', :prompt => /\(config-vlan\)#\s?\z/n)
      @transport.expects(:command).with('name VLAN1105')
      @transport.expects(:command).with('exit')
      @transport.stubs(:command).with("sh vlan brief", {:cache => true, :noop => false}).returns(@vlan_config)
      @vlan.evaluate_new_params
      @vlan.update({:ensure => :present, :desc => 'SERVER-INTERN'}, {:ensure => :present, :desc => 'VLAN1105'})
    end

    it 'should remove a vlan' do
      @transport.expects(:command).with('no vlan 1105')
      @transport.stubs(:command).with("sh vlan brief", {:cache => true, :noop => false}).returns(@vlan_config)
      @vlan.evaluate_new_params
      @vlan.update({:ensure => :present}, {:ensure => :absent})
    end
  end
end
