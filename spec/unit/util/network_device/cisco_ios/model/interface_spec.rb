#! /usr/bin/env ruby
require 'spec_helper'
require 'puppet/util/network_device'
require 'puppet/util/network_device/cisco_ios/model/interface'

describe Puppet::Util::NetworkDevice::Cisco_ios::Model::Interface do
  before(:each) do
    @transport = stub_everything "transport"
    @interface = Puppet::Util::NetworkDevice::Cisco_ios::Model::Interface.new(@transport, {}, { :name => 'FastEthernet2/0/2' })
  end

  describe 'when working with interface params' do
    before do
      @interface_config = <<END
interface FastEthernet2/0/1
 description foreman test host
 switchport access vlan 100
 switchport mode access
 switchport nonegotiate
 switchport port-security
 switchport port-security aging time 1
 switchport port-security violation restrict
 switchport port-security aging type inactivity
 spanning-tree portfast
 spanning-tree bpduguard enable
 ip dhcp snooping limit rate 5
!
interface FastEthernet2/0/2
 description foreman prod host
 switchport access vlan 200
 switchport mode access
 switchport nonegotiate
 switchport port-security
 switchport port-security aging time 1
 switchport port-security violation restrict
 switchport port-security aging type inactivity
 spanning-tree portfast
 spanning-tree bpduguard enable
 ip dhcp snooping limit rate 5
!
interface FastEthernet2/0/3
 description foreman prod host
 switchport access vlan 200
 switchport mode trunk
 ip dhcp snooping limit rate 5
!
END
    end

    it 'should initialize various base params' do
      @interface.params.should_not == be_empty
    end

    it 'should set the name from the options' do
      @interface.name.should == 'FastEthernet2/0/2'
    end

    it 'should set the scope_name on the description param' do
      @interface.params[:description].scope_name.should == 'FastEthernet2/0/2'
    end

    it 'should parse the description param' do
      @transport.stubs(:command).with('sh run', {:cache => true, :noop => false}).returns(@interface_config)
      @interface.evaluate_new_params
      @interface.params[:description].value.should == 'foreman prod host'
    end

    it 'should not enter interface configuration mode if nothings changed' do
      @transport.expects(:command).with('interface FastEthernet2/0/2', {:cache => true, :noop => false}).never
      @interface.evaluate_new_params
      @interface.update()
    end

    it 'should update the value' do
      @transport.expects(:command).with('description test2')
      @transport.stubs(:command).with('sh run', {:cache => true, :noop => false}).returns(@interface_config)
      @interface.evaluate_new_params
      @interface.update({:description => 'foreman prod host'}, {:description => 'test2'})
    end

    it 'should remove the value' do
      @transport.expects(:command).with('no description foreman prod host').once
      @transport.stubs(:command).with('sh run', {:cache => true, :noop => false}).returns(@interface_config)
      @interface.evaluate_new_params
      @interface.update({:description => 'foreman prod host'}, {:description => :absent})
    end

    it 'should add the value' do
      @transport.expects(:command).with('description test2')
      @transport.stubs(:command).with("sh run", {:cache => true, :noop => false}).returns("interface FastEthernet2/0/2\n!")
      @interface.evaluate_new_params
      @interface.update({}, {:description => 'test2'})
    end

    describe 'when managing interfaces' do
      it 'should execute the commands in the right sequence' do
        seq = sequence('commands')
        @transport.stubs(:command).with("sh run", {:cache => true, :noop => false}).returns("interface FastEthernet2/0/2\n!")
        ['description foobar', 'switchport mode access'].each do |cmd|
          @transport.expects(:command).with(cmd).in_sequence(seq)
        end
        ['switchport nonegotiate', 'switchport port-security', 'switchport port-security violation restrict',
         'switchport port-security aging time 1', 'switchport port-security aging type inactivity', 'spanning-tree portfast',
         'spanning-tree bpduguard enable', 'ip dhcp snooping limit rate 5'].each do |cmd|
           @transport.expects(:command).with(cmd)
         end
         @interface.evaluate_new_params
         @interface.update({}, {:description => 'foobar',
                                :mode => 'access',
                                :access => '1106',
                                :negotiate => :false,
                                :dhcp_snooping_limit_rate => '5',
                                :port_security => 'restrict',
                                :port_security_aging_type => 'inactivity',
                                :port_security_aging_time => '1',
                                :spanning_tree => :leaf,
                                :spanning_tree_bpduguard => :present})
      end
      it 'should be possible to manage uplink ports' do
        @transport.stubs(:command).with("sh run", {:cache => true, :noop => false}).returns("interface FastEthernet2/0/2\n!")
        ['description uplink', 'switchport trunk encapsulation dot1q', 'switchport mode trunk', 'ip dhcp snooping trust'].each do |cmd|
          @transport.expects(:command).with(cmd)
        end
        @interface.evaluate_new_params
        @interface.update({}, {:description => 'uplink',
                              :mode => 'trunk',
                              :trunk_encapsulation => 'dot1q',
                              :negotiate => :true,
                              :spanning_tree => :leaf,
                              :spanning_tree_bpduguard => :present,
                              :dhcp_snooping_trust => :present})
      end

      it 'should not try to set encapsulation on a C4500' do
        @interface = Puppet::Util::NetworkDevice::Cisco_ios::Model::Interface.new(@transport, {'canonicalized_hardwaremodel' => 'c4500'}, { :name => 'FastEthernet2/0/2' })
        @transport.stubs(:command).with("sh run", {:cache => true, :noop => false}).returns("interface FastEthernet2/0/2\n!")
        ['description uplink', 'switchport mode trunk', 'ip dhcp snooping trust'].each do |cmd|
          @transport.expects(:command).with(cmd)
        end
        @interface.evaluate_new_params
        @interface.update({}, {:description => 'uplink',
                              :mode => 'trunk',
                              :trunk_encapsulation => 'dot1q',
                              :negotiate => :true,
                              :spanning_tree => :leaf,
                              :spanning_tree_bpduguard => :present,
                              :dhcp_snooping_trust => :present})
      end
    end
  end
end
