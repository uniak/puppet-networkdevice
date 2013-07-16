#! /usr/bin/env ruby
require 'spec_helper'

describe Puppet::Type.type(:cisco_snmp_server) do

  let(:name) { :running }

  it "should have a 'name' parameter'" do
    described_class.new(:name => "running")[:name].should == :running
  end
  it "should be applied on device" do
    described_class.new(:name => "running").must be_appliable_to_device
  end

  [:chassis_id, :contact, :enable_traps, :engineid_local,
   :file_transfer_access_group, :ifindex_persist, :inform_pending,
   :inform_retries, :inform_timeout, :ip_dscp, :ip_precedence, :location,
   :manager, :manager_session_timeout, :packetsize, :queue_length,
   :source_interface_informs, :source_interface_traps,
   :system_shutdown, :tftp_server_list, :trap_source, :trap_timeout].each do |p|
    it "should have a #{p} property" do
      described_class.attrtype(p).should == :property
    end
  end

  describe "when validating attribute values" do
    before do
      @provider = stub 'provider', :class => described_class.defaultprovider, :clear => nil
      described_class.defaultprovider.stubs(:new).returns(@provider)
    end

    describe "chassis_id" do
      it "should allow any valid string" do
        described_class.new(:name => :running, :chassis_id => 'foo-bar')
      end

      it "should allow :absent" do
        described_class.new(:name => :running, :chassis_id => :absent)
      end

      it "should raise an exception on strings containing spaces" do
        expect { described_class.new(:name => :running, :chassis_id => 'foo bar') }.to raise_error
      end
    end

    describe "contact" do
      it "should allow any valid string" do
        described_class.new(:name => :running, :chassis_id => 'foo-bar')
      end

      it "should allow :absent" do
        described_class.new(:name => :running, :chassis_id => :absent)
      end

      it "should raise an exception on strings containing spaces" do
        expect { described_class.new(:name => :running, :chassis_id => 'foo bar') }.to raise_error
      end
    end

    describe "enable_traps" do
      [:absent, "auth-framework", "bridge", "cef", "cluster",
      "config", "config-copy", "config-ctid", "copy-config",
      "cpu", "dot1x", "eigrp", "energywise", "entity", "envmon",
      "errdisable", "event-manager", "flash", "fru-ctrl", "hsrp",
      "ipmulticast", "license", "mac-notification", "ospf", "pim",
      "port-security", "power-ethernet", "rtr", "snmp", "stackwise",
      "storm-control", "stpx", "syslog", "transceiver all", "tty",
      "vlan-membership", "vlancreate", "vlandelete", "vstack", "vtp"].each do |snmp_trap|
        it "should allow trap #{snmp_trap}" do
          described_class.new(:name => :running, :enable_traps => snmp_trap)
        end
      end
    end

    describe "engineid_local" do
      it "should allow any valid string" do
        described_class.new(:name => :running, :engineid_local => 'foo-bar')
      end

      it "should allow :absent" do
        described_class.new(:name => :running, :engineid_local => :absent)
      end

      it "should raise an exception on strings containing spaces" do
        expect { described_class.new(:name => :running, :engineid_local => 'foo bar') }.to raise_error
      end
    end

    describe "file_transfer_access_group" do
      it "should allow any valid string" do
        described_class.new(:name => :running, :file_transfer_access_group => 'foo-bar')
      end

      it "should allow any number" do
        described_class.new(:name => :running, :file_transfer_access_group => 99)
      end

      it "should allow :absent" do
        described_class.new(:name => :running, :file_transfer_access_group => :absent)
      end

      it "should raise an exception on strings containing spaces" do
        expect { described_class.new(:name => :running, :file_transfer_access_group => 'foo bar') }.to raise_error
      end
    end

    describe "ifindex_persist" do
      it_behaves_like "ensureable" do
        let(:prop) { :ifindex_persist }
      end
    end

    describe "inform_pending" do
      it "should allow any number between 1-4294967295" do
        described_class.new(:name => :running, :inform_pending => 100)
      end
      it "should raise an exception on an invalid value of 0" do
        expect { described_class.new(:name => :running, :inform_pending => 0) }.to raise_error
      end
      it "should raise an exception on an invalid value of 4294967296" do
        expect { described_class.new(:name => :running, :inform_pending => 4294967296) }.to raise_error
      end
    end

    describe "inform_retries" do
      it "should allow any number between 1-100" do
        described_class.new(:name => :running, :inform_retries => 50)
      end
      it "should raise an exception on an invalid value of 0" do
        expect { described_class.new(:name => :running, :inform_retries => 0) }.to raise_error
      end
      it "should raise an exception on an invalid value of 101" do
        expect { described_class.new(:name => :running, :inform_retries => 101) }.to raise_error
      end
    end

    describe "inform_timeout" do
      it "should allow any number between 1-4294967295" do
        described_class.new(:name => :running, :inform_timeout => 100)
      end
      it "should raise an exception on an invalid value of 0" do
        expect { described_class.new(:name => :running, :inform_timeout => 0) }.to raise_error
      end
      it "should raise an exception on an invalid value of 4294967296" do
        expect { described_class.new(:name => :running, :inform_timeout => 4294967296) }.to raise_error
      end
    end

    describe "ip_dscp" do
      it "should allow any number between 0-63" do
        described_class.new(:name => :running, :ip_dscp => 50)
      end
      it "should raise an exception on an invalid value of -1" do
        expect { described_class.new(:name => :running, :ip_dscp => -1) }.to raise_error
      end
      it "should raise an exception on an invalid value of 64" do
        expect { described_class.new(:name => :running, :ip_dscp => 64) }.to raise_error
      end
    end

    describe "ip_precedence" do
      it "should allow any number between 0-7" do
        described_class.new(:name => :running, :ip_precedence => 7)
      end
      it "should raise an exception on an invalid value of -1" do
        expect { described_class.new(:name => :running, :ip_precedence => -1) }.to raise_error
      end
      it "should raise an exception on an invalid value of 8" do
        expect { described_class.new(:name => :running, :ip_precedence => 8) }.to raise_error
      end
    end

    describe "location" do
      it "should allow any valid string" do
        described_class.new(:name => :running, :location => 'foo-bar')
      end

      it "should allow :absent" do
        described_class.new(:name => :running, :location => :absent)
      end

      it "should raise an exception on strings containing spaces" do
        expect { described_class.new(:name => :running, :location => 'foo bar') }.to raise_error
      end
    end

    describe "manager" do
      it_behaves_like "ensureable" do
        let(:prop) { :manager }
      end
    end

    describe "manager_session_timeout" do
      it "should allow any number between 10-2147483" do
        described_class.new(:name => :running, :manager_session_timeout => 100)
      end
      it "should raise an exception on an invalid value of 9" do
        expect { described_class.new(:name => :running, :manager_session_timeout => 9) }.to raise_error
      end
      it "should raise an exception on an invalid value of 2147484" do
        expect { described_class.new(:name => :running, :manager_session_timeout => 2147484) }.to raise_error
      end
    end

    describe "packetsize" do
      it "should allow any number between 484-17892" do
        described_class.new(:name => :running, :packetsize => 1000)
      end
      it "should raise an exception on an invalid value of 250" do
        expect { described_class.new(:name => :running, :packetsize => 250) }.to raise_error
      end
      it "should raise an exception on an invalid value of 17893" do
        expect { described_class.new(:name => :running, :packetsize => 17893) }.to raise_error
      end
    end

    describe "queue_length" do
      it "should allow any number between 1-5000" do
        described_class.new(:name => :running, :queue_length => 100)
      end
      it "should raise an exception on an invalid value of 0" do
        expect { described_class.new(:name => :running, :queue_length => 0) }.to raise_error
      end
      it "should raise an exception on an invalid value of 5001" do
        expect { described_class.new(:name => :running, :queue_length => 5001) }.to raise_error
      end
    end

    describe "source_interface_informs" do
      it "should allow any valid string" do
        described_class.new(:name => :running, :source_interface_informs => 'foo-bar')
      end

      it "should allow :absent" do
        described_class.new(:name => :running, :source_interface_informs => :absent)
      end

      it "should raise an exception on strings containing spaces" do
        expect { described_class.new(:name => :running, :source_interface_informs => 'foo bar') }.to raise_error
      end
    end

    describe "source_interface_traps" do
      it "should allow any valid string" do
        described_class.new(:name => :running, :source_interface_traps => 'foo-bar')
      end

      it "should allow :absent" do
        described_class.new(:name => :running, :source_interface_traps => :absent)
      end

      it "should raise an exception on strings containing spaces" do
        expect { described_class.new(:name => :running, :source_interface_traps => 'foo bar') }.to raise_error
      end
    end

    describe "system_shutdown" do
      it_behaves_like "ensureable" do
        let(:prop) { :system_shutdown }
      end
    end

    describe "tftp_server_list" do
      it "should allow any valid string" do
        described_class.new(:name => :running, :tftp_server_list => 'foo-bar')
      end

      it "should allow any number" do
        described_class.new(:name => :running, :tftp_server_list => 99)
      end

      it "should allow :absent" do
        described_class.new(:name => :running, :tftp_server_list => :absent)
      end

      it "should raise an exception on strings containing spaces" do
        expect { described_class.new(:name => :running, :tftp_server_list => 'foo bar') }.to raise_error
      end
    end

    describe "trap_source" do
      it "should allow any valid string" do
        described_class.new(:name => :running, :trap_source => 'foo-bar')
      end

      it "should allow :absent" do
        described_class.new(:name => :running, :trap_source => :absent)
      end

      it "should raise an exception on strings containing spaces" do
        expect { described_class.new(:name => :running, :trap_source => 'foo bar') }.to raise_error
      end
    end

    describe "trap_timeout" do
      it "should allow any number between 1-1000" do
        described_class.new(:name => :running, :trap_timeout => 100)
      end
      it "should raise an exception on an invalid value of 0" do
        expect { described_class.new(:name => :running, :trap_timeout => 0) }.to raise_error
      end
      it "should raise an exception on an invalid value of 1001" do
        expect { described_class.new(:name => :running, :trap_timeout => 1001) }.to raise_error
      end
    end

  end
end
