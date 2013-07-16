#! /usr/bin/env ruby
require 'spec_helper'

describe Puppet::Type.type(:cisco_config) do

  let(:name) { :running }

  it "should have a 'name' parameter'" do
    described_class.new(:name => "running")[:name].should == name
  end

  it "should be applied on device" do
    described_class.new(:name => name).must be_appliable_to_device
  end

  [:name].each do |p|
    it "should have a #{p} param" do
      described_class.attrtype(p).should == :param
    end
  end

  [:hostname, :ip_domain_name, :ntp_servers, :logging_servers, :clock_timezone, :system_mtu_routing,
   :ip_classless, :ip_domain_lookup, :ip_domain_lookup_source_interface, :ip_name_servers, :ip_default_gateway,
   :ip_radius_source_interface, :logging_trap, :logging_facility,
   :vtp_version, :vtp_operation_mode, :vtp_password, :errdisable_recovery_cause, :errdisable_recovery_interval].each do |p|
    it "should have a #{p} property" do
      described_class.attrtype(p).should == :property
    end
  end

  describe "when validating attribute values" do
    before do
      @provider = stub 'provider', :class => described_class.defaultprovider, :clear => nil
      described_class.defaultprovider.stubs(:new).returns(@provider)
    end

    describe "name" do
      it "should allow '#{name}'" do
        described_class.new(:name => name)
      end

      it "should raise an exception on everything else" do
        expect { described_class.new(:name => "foobar") }.to raise_error
      end
    end

    describe "hostname" do
      it "should allow any valid string" do
        described_class.new(:name => name, :hostname => 'foo-bar')
      end

      it "should raise an exception on strings containing spaces" do
        expect { described_class.new(:name => name, :hostname => 'foo bar') }.to raise_error
      end
    end

    describe "ip_domain_name" do
      it "should allow everything that looks like a domain" do
        described_class.new(:name => name, :ip_domain_name => 'foo.bar')
      end

      it "should raise an exception if the supplied value doesn't look like a domain" do
        expect { described_class.new(:name => name, :ip_domain_name => 'foobar') }.to raise_error
      end
    end

    describe "ntp_servers" do
      it_behaves_like "newhostlistprop" do
        let(:prop) { :ntp_servers }
      end
    end

    describe "logging_servers" do
      it_behaves_like "newhostlistprop" do
        let(:prop) { :logging_servers }
      end
    end

    describe "clock_timezone" do
      it "should allow a value without a minutes-offset" do
        described_class.new(:name => name, :clock_timezone => "CEST 1")
      end

      it "should allow a value with a minutes-offset" do
        described_class.new(:name => name, :clock_timezone => "CEST 1 1")
      end

      it "should allow a value with a negative offset" do
        described_class.new(:name => name, :clock_timezone => "PST -8")
      end

      it "should raise an exception on everyhting else" do
        expect { described_class.new(:name => name, :clock_timezone => "foobar") }.to raise_error
      end
    end

    describe "system_mtu_routing" do
      it "should allow a string containing only digets" do
        described_class.new(:name => name, :system_mtu_routing => "1500")
      end

      it "should allow digets" do
        described_class.new(:name => name, :system_mtu_routing => 1500)
      end

      it "should raise an exception on everyhting else" do
        expect { described_class.new(:name => name, :system_mtu_routing => "foobar") }.to raise_error
      end
    end

    describe "ip_classless" do
      it_behaves_like "ensureable" do
        let(:prop) { :ip_classless }
      end
    end

    describe "ip_domain_lookup" do
      it_behaves_like "ensureable" do
        let(:prop) { :ip_domain_lookup }
      end
    end

    describe "ip_domain_lookup_source_interface" do
      it "should allow any valid string" do
        described_class.new(:name => name, :ip_domain_lookup_source_interface => 'foo-bar')
      end

      it "should allow :absent" do
        described_class.new(:name => name, :ip_domain_lookup_source_interface => :absent)
      end

      it "should raise an exception on strings containing spaces" do
        expect { described_class.new(:name => name, :ip_domain_lookup_source_interface => 'foo bar') }.to raise_error
      end
    end

    describe "ip_name_servers" do
      it_behaves_like "newhostlistprop" do
        let(:prop) { :ip_name_servers }
      end
    end

    describe "ip_default_gateway" do
      it "should allow any valid IP" do
        described_class.new(:name => name, :ip_default_gateway => "192.168.0.1")
      end

      it "should allow :absent" do
        described_class.new(:name => name, :ip_default_gateway => :absent)
      end

      it "should raise an exception on everything else" do
        expect { described_class.new(:name => name, :ip_default_gateway => "foobar") }.to raise_error
      end
    end

    describe "ip_radius_source_interface" do
      it "should allow any valid string" do
        described_class.new(:name => name, :ip_radius_source_interface => 'foo-bar')
      end

      it "should allow :absent" do
        described_class.new(:name => name, :ip_radius_source_interface => :absent)
      end

      it "should raise an exception on strings containing spaces" do
        expect { described_class.new(:name => name, :ip_radius_source_interface => 'foo bar') }.to raise_error
      end
    end

    describe "logging_trap" do
      [:emergencies, :alerts, :critical, :errors, :warnings, :notifications, :informational, :debugging].each do |lvl|
        it "should allow lvl #{lvl}" do
          described_class.new(:name => name, :logging_trap => lvl)
        end
      end

      (0..7).each do |lvl|
        it "should allow a numerical lvl of #{lvl}" do
          described_class.new(:name => name, :logging_trap => lvl)
        end
      end

      it "should raise an exception on everything else" do
        expect { described_class.new(:name => name, :logging_trap => "foobar") }.to raise_error
      end
    end

    describe "logging_facility" do
      [:auth, :cron, :daemon, :kern, :local0, :lpr, :mail, :news, :sys9, :syslog, :user, :uucp].each do |facility|
        it "should allow facility #{facility}" do
          described_class.new(:name => name, :logging_facility => facility)
        end
      end

      it "should raise an expection on everything else" do
        expect { described_class.new(:name => name, :logging_facility => "foobar") }.to raise_error
      end
    end

    describe "vtp_version" do
      (1..3).each do |num|
        it "should allow #{num}" do
          described_class.new(:name => name, :vtp_version => num)
        end
      end

      it "should allow :absent" do
        described_class.new(:name => name, :vtp_version => :absent)
      end

      it "should raise an exception on everything else" do
        expect { described_class.new(:name => :number, :vtp_version => "foobar") }.to raise_error
      end
    end

    describe "vtp_operation_mode" do
      ["client", "off", "server", "transparent", "client mst", "off unknown", "server vlan"].each do |mode|
        it "should allow mode #{mode}" do
          described_class.new(:name => name, :vtp_operation_mode => mode)
        end
      end

      it "should raise an exception on everything else" do
        expect { described_class.new(:name => name, :vtp_operation_mode => "foo bar") }.to raise_error
      end
    end

    describe "vtp_password" do
      it "should allow a string without spaces" do
        described_class.new(:name => name, :vtp_password => "foobar")
      end

      it "should raise an exception on everything else" do
        expect { described_class.new(:name => name, :vtp_password => "foo bar")}
      end
    end

    describe "enable_secret"  do
      it "should allow a string without spaces" do
        described_class.new(:name => name, :enable_secret => "foobar")
      end

      it "should allow :absent" do
        described_class.new(:name => name, :enable_secret => :absent)
      end

      it "should raise an exception on everything else" do
        expect { described_class.new(:name => name, :enable_secret => "foo bar")}
      end
    end

    describe "ip_dhcp_snooping" do
      it "should allow :present" do
        described_class.new(:name => name, :ip_dhcp_snooping => :present)
      end

      it "should allow :absent" do
        described_class.new(:name => name, :ip_dhcp_snooping => :absent)
      end

      it "should raise an exception on everything else" do
        expect { described_class.new(:name => name, :ip_dhcp_snooping => "foobar") }.to raise_error
      end
    end

    describe "ip_dhcp_snooping_vlans" do
      it "should allow a single vlan" do
        described_class.new(:name => name, :ip_dhcp_snooping_vlans => "1000")
      end

      it "should allow a vlan range" do
        described_class.new(:name => name, :ip_dhcp_snooping_vlans => "1000-1100")
      end

      it "should allow :absent" do
        described_class.new(:name => name, :ip_dhcp_snooping_vlans => :absent)
      end

      it "should raise an exception on everything else" do
        expect { described_class.new(:name => name, :ip_dhcp_snooping_vlans => "foobar") }.to raise_error
      end
    end

    describe "ip_dhcp_snooping_remote_id" do
      it "should allow :hostname" do
        described_class.new(:name => name, :ip_dhcp_snooping_remote_id => :hostname)
      end

      it "should allow a string without spaces" do
        described_class.new(:name => name, :ip_dhcp_snooping_remote_id => "foobar")
      end

      it "should allow :absent" do
        described_class.new(:name => name, :ip_dhcp_snooping_remote_id => :absent)
      end

      it "should raise an exception on everything else" do
        expect { described_class.new(:name => name, :ip_dhcp_snooping_remote_id => "foo bar") }.to raise_error
      end
    end

    describe "ip_dhcp_relay_information" do
      [:trust_all, :check, :policy_encapsulate, :policy_drop, :policy_keep, :policy_replace].each do |mode|
        it "should allow #{mode}" do
          described_class.new(:name => name, :ip_dhcp_relay_information => mode)
        end
      end
    end

    describe "password_encryption" do
      [:present, :absent].each do |mode|
        it "should allow #{mode}" do
          described_class.new(:name => name, :password_encryption => mode)
        end
      end

      it "should raise an exception on everything else" do
        expect { described_class.new(:name => name, :password_encryption => "foo bar") }.to raise_error
      end
    end

    describe "errdisable_recovery_cause" do
      [:absent, 'arp-inspection', 'bpduguard', 'channel-misconfig',
      'community-limit', 'dhcp-rate-limit', 'dtp-flap',
      'gbic-invalid', 'inline-power', 'invalid-policy', 'l2ptguard',
      'link-flap', 'loopback', 'lsgroup', 'mac-limit', 'pagp-flap',
      'port-mode-failure', 'pppoe-ia-rate-limit', 'psecure-violation',
      'security-violation', 'sfp-config-mismatch', 'small-frame',
      'storm-control', 'udld', 'vmps'].each do |value|
        it "should allow #{value}" do
          described_class.new(:name => name, :errdisable_recovery_cause => value)
        end
      end

      it "should raise an exception on everything else" do
        expect { described_class.new(:name => name, :errdisable_recovery_cause => :foobar) }.to raise_error
      end
    end

    describe "errdisable_recovery_interval" do
      [:absent, 30, 500, 86400].each do |value|
        it "should allow #{value}" do
          described_class.new(:name => name, :errdisable_recovery_interval => value)
        end
      end

      [1, 29, 86401].each do |value|
        it "should raise an exception on the invalid value #{value}" do
          expect { described_class.new(:name => name, :errdisable_recovery_interval => value) }.to raise_error
        end
      end
    end
  end
end
