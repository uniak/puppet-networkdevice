#! /usr/bin/env ruby
require 'spec_helper'
require 'puppet/util/network_device'
require 'puppet/util/network_device/cisco_ios/model/snmp'

describe Puppet::Util::NetworkDevice::Cisco_ios::Model::Snmp do
  before(:each) do
    @transport = stub_everything 'transport'
    @snmp = described_class.new(@transport, {}, {:name => :running})
  end

  describe 'when working with snmp_host params' do
    before do
      @snmp_config = <<EOF
snmp-server contact foo@bar
snmp-server chassis-id foobar
snmp-server engineID local 1234
snmp-server file-transfer access-group foobar
snmp ifmib ifindex persist
snmp-server enable traps vtp
snmp-server enable traps port-security
snmp-server inform pending 20
snmp-server inform retries 20
snmp-server inform timeout 20
snmp-server ip dscp 10
snmp-server ip precedence 5
snmp-server location foobar
snmp-server manager
snmp-server manager session-timeout 10
snmp-server packetsize 1000
snmp-server queue-length 10
snmp-server source-interface informs FastEthernet1/0/1
snmp-server source-interface traps FastEthernet1/0/1
snmp-server system-shutdown
snmp-server tftp-server-list foobar
snmp-server trap-source FastEthernet1/0/1
snmp-server trap-timeout 10
EOF
    end

    it 'should initialize various base params' do
      @snmp.params.should_not == be_empty
    end

    it 'should set the name from the options' do
      @snmp.name.should == :running
    end

    {:chassis_id => "foobar", :contact => "foo@bar", :enable_traps => ["vtp", "port-security"],
     :engineid_local => "1234", :file_transfer_access_group => "foobar",
     :ifindex_persist => :present, :inform_pending => "20", :inform_retries => "20",
     :inform_timeout => "20", :ip_dscp => "10", :ip_precedence => "5", :location => "foobar",
     :manager => :present, :manager_session_timeout => "10", :packetsize => "1000",
     :queue_length => "10", :source_interface_informs => "FastEthernet1/0/1",
     :source_interface_traps => "FastEthernet1/0/1", :system_shutdown => :present,
     :tftp_server_list => "foobar", :trap_source => "FastEthernet1/0/1", :trap_timeout=>"10"}.each do |k,v|
      it "should parse the #{k} param" do
        @transport.stubs(:command).with('sh run', {:cache => true, :noop => false}).returns(@snmp_config)
        @snmp.evaluate_new_params
        @snmp.params[k].value.should == v
      end
    end
  end
end
