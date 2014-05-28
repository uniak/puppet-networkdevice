#! /usr/bin/env ruby
require 'spec_helper'

require 'puppet/util/network_device'
require 'puppet/util/network_device/cisco_ios/facts'

describe Puppet::Util::NetworkDevice::Cisco_ios::Facts do
  before(:each) do
    @transport = stub_everything 'transport'
    @facts = Puppet::Util::NetworkDevice::Cisco_ios::Facts.new(@transport)
  end

  {
    "cisco WS-C2924C-XL (PowerPC403GA) processor (revision 0x11) with 8192K/1024K bytes of memory." => {
      "canonicalized_hardwaremodel" => "c2924",
      "hardwaremodel" => "WS-C2924C-XL",
      "memorysize" => "8192K",
      "processor" => "PowerPC403GA",
      "hardwarerevision" => "0x11"
    },
    "Cisco 1841 (revision 5.0) with 355328K/37888K bytes of memory." => {
      "canonicalized_hardwaremodel" => "c1841",
      "hardwaremodel"=>"1841",
      "memorysize" => "355328K",
      "hardwarerevision" => "5.0"
    },
    "Cisco 877 (MPC8272) processor (revision 0x200) with 118784K/12288K bytes of memory." => {
      "canonicalized_hardwaremodel" => "c877",
      "hardwaremodel"=>"877",
      "memorysize" => "118784K",
      "processor" => "MPC8272",
      "hardwarerevision" => "0x200"
    },
    "cisco WS-C2960G-48TC-L (PowerPC405) processor (revision C0) with 61440K/4088K bytes of memory." => {
      "canonicalized_hardwaremodel" => "c2960",
      "hardwaremodel"=>"WS-C2960G-48TC-L",
      "memorysize" => "61440K",
      "processor" => "PowerPC405",
      "hardwarerevision" => "C0"
    },
    "cisco WS-C2950T-24 (RC32300) processor (revision R0) with 19959K bytes of memory." => {
      "canonicalized_hardwaremodel" => "c2950",
      "hardwaremodel"=>"WS-C2950T-24",
      "memorysize" => "19959K",
      "processor" => "RC32300",
      "hardwarerevision" => "R0"
    },
    "cisco WS-C3750-24TS (PowerPC405) processor (revision K0) with 131072K bytes of memory." => {
      "canonicalized_hardwaremodel" => "c3750",
      "hardwaremodel" => "WS-C3750-24TS",
      "memorysize" => "131072K",
      "processor" => "PowerPC405",
      "hardwarerevision" => "K0"
    },
    "cisco WS-C4506-E (MPC8572) processor (revision 10) with 2097152K/20480K bytes of memory." => {
      "canonicalized_hardwaremodel" => "c4500",
      "hardwaremodel" => "WS-C4506-E",
      "memorysize" => "2097152K",
      "processor" => "MPC8572",
      "hardwarerevision" => "10"
    },
    "cisco WS-C6509-E (R7000) processor (revision 1.4) with 983008K/65536K bytes of memory." => {
      "canonicalized_hardwaremodel" => "c6509",
      "hardwaremodel" => "WS-C6509-E",
      "memorysize" => "983008K",
      "processor" => "R7000",
      "hardwarerevision" => "1.4"
    },
    "cisco WS-C4507R+E (MPC8548) processor (revision 12) with 524288K bytes of memory." => {
      "canonicalized_hardwaremodel" => "c4500",
      "hardwaremodel" => "WS-C4507R+E",
      "memorysize" => "524288K",
      "processor" => "MPC8548",
      "hardwarerevision" => "12"
    }
  }.each do |ver, expected|
    it "should parse show ver output for hardware device facts" do
      @transport.stubs(:command).with("sh ver", {:cache => true, :noop => false}).returns(<<eos)
Switch>sh ver
#{ver}
Switch>
eos
      @facts.retrieve.should == expected
    end
  end

  {
    "Switch uptime is 1 year, 12 weeks, 6 days, 22 hours, 32 minutes" => {
      "hostname" => "switch",
      "uptime" => "1 year, 12 weeks, 6 days, 22 hours, 32 minutes",
      "uptime_seconds" => 39393120,
      "uptime_days" => 455
    },
    "c2950 uptime is 3 weeks, 1 day, 23 hours, 36 minutes" => {
      "hostname" => "c2950",
      "uptime" => "3 weeks, 1 day, 23 hours, 36 minutes",
      "uptime_days" => 22,
      "uptime_seconds" =>  1985760
    },
    "router uptime is 5 weeks, 1 day, 3 hours, 30 minutes" => {
      "hostname" => "router",
      "uptime" => "5 weeks, 1 day, 3 hours, 30 minutes",
      "uptime_days" => 36,
      "uptime_seconds" => 3123000
    },
    "c2950 uptime is 1 minute" => {
      "hostname" => "c2950",
      "uptime" => "1 minute",
      "uptime_days" => 0,
      "uptime_seconds" => 60
    },
    "c2950 uptime is 20 weeks, 6 minutes" => {
      "hostname" => "c2950",
      "uptime" => "20 weeks, 6 minutes",
      "uptime_seconds" => 12096360,
      "uptime_days" => 140
    },
    "c2950 uptime is 2 years, 20 weeks, 6 minutes" => {
      "hostname" => "c2950",
      "uptime" => "2 years, 20 weeks, 6 minutes",
      "uptime_seconds" => 75168360,
      "uptime_days" => 870
    },
    "c3750 uptime is 5 weeks, 6 days, 26 minutes" => {
      "hostname" => "c3750",
      "uptime" => "5 weeks, 6 days, 26 minutes",
      "uptime_seconds" => 3543960,
      "uptime_days" => 41
    },
    # ignore leading space, too
    " c3750 uptime is 5 weeks, 6 days, 26 minutes" => {
      "hostname" => "c3750",
      "uptime" => "5 weeks, 6 days, 26 minutes",
      "uptime_seconds" => 3543960,
      "uptime_days" => 41
    }
  }.each do |ver, expected|
    it "should parse show ver output for device uptime facts" do
      @transport.stubs(:command).with("sh ver", {:cache => true, :noop => false}).returns(<<eos)
Switch>sh ver
#{ver}
Switch>
eos
      @facts.retrieve.should == expected
    end
  end

  describe "when constructing fqdn from host and domain name" do
    it "should return host.domain" do
      @transport.stubs(:command).with("sh ver", {:cache => true, :noop => false}).returns(<<eos)
Switch>sh ver
c3750 uptime is 5 weeks, 6 days, 26 minutes
Switch>
eos
      @transport.stubs(:command).with("sh run", {:cache => true, :noop => false}).returns(<<eos)
Switch>sh run
ip domain-name example.com
Switch>
eos
      @facts.retrieve['fqdn'].should == 'c3750.example.com'
    end

    it "should lowercase hostname and fqdn" do
      @transport.stubs(:command).with("sh ver", {:cache => true, :noop => false}).returns(<<eos)
Switch>sh ver
HOSTNAME uptime is 5 weeks, 6 days, 26 minutes
Switch>
eos
      @transport.stubs(:command).with("sh run", {:cache => true, :noop => false}).returns(<<eos)
Switch>sh run
ip domain-name EXAMPLE.COM
Switch>
eos
      @facts.retrieve['fqdn'].should == 'hostname.example.com'
    end

    it "should not create fqdn whithout domain" do
      @transport.stubs(:command).with("sh ver", {:cache => true, :noop => false}).returns(<<eos)
Switch>sh ver
c3750 uptime is 5 weeks, 6 days, 26 minutes
Switch>
eos
      @transport.stubs(:command).with("sh run", {:cache => true, :noop => false}).returns(<<eos)
Switch>sh run
Switch>
eos
      @facts.retrieve.should_not have_key('fqdn')
    end

    it "should not create fqdn whithout host" do
      @transport.stubs(:command).with("sh ver", {:cache => true, :noop => false}).returns(<<eos)
Switch>sh ver
uptime is 5 weeks, 6 days, 26 minutes
Switch>
eos
      @transport.stubs(:command).with("sh run", {:cache => true, :noop => false}).returns(<<eos)
Switch>sh run
ip domain-name example.com
Switch>
eos
      @facts.retrieve.should_not have_key('fqdn')
    end
  end

  {
    "IOS (tm) C2900XL Software (C2900XL-C3H2S-M), Version 12.0(5)WC10, RELEASE SOFTWARE (fc1)" => {
      "operatingsystem" => "IOS",
      "operatingsystemplatform" => "C2900XL",
      "operatingsystemrelease" => "12.0(5)WC10",
      "operatingsystemmajrelease" => "12.0WC",
      "operatingsystemfeature" => "C3H2S"
    },
    "IOS (tm) C2950 Software (C2950-I6K2L2Q4-M), Version 12.1(22)EA8a, RELEASE SOFTWARE (fc1)" => {
      "operatingsystem" => "IOS",
      "operatingsystemplatform" => "C2950",
      "operatingsystemrelease" => "12.1(22)EA8a",
      "operatingsystemmajrelease" => "12.1EA",
      "operatingsystemfeature" => "I6K2L2Q4"
    },
    "Cisco IOS Software, C2960 Software (C2960-LANBASEK9-M), Version 12.2(44)SE, RELEASE SOFTWARE (fc1)" => {
      "operatingsystem" => "IOS",
      "operatingsystemplatform" => "C2960",
      "operatingsystemrelease" => "12.2(44)SE",
      "operatingsystemmajrelease" => "12.2SE",
      "operatingsystemfeature" => "LANBASEK9"
    },
    "Cisco IOS Software, C870 Software (C870-ADVIPSERVICESK9-M), Version 12.4(11)XJ4, RELEASE SOFTWARE (fc2)" => {
      "operatingsystem" => "IOS",
      "operatingsystemplatform" => "C870",
      "operatingsystemrelease" => "12.4(11)XJ4",
      "operatingsystemmajrelease" => "12.4XJ",
      "operatingsystemfeature" => "ADVIPSERVICESK9"
    },
    "Cisco IOS Software, 1841 Software (C1841-ADVSECURITYK9-M), Version 12.4(24)T4, RELEASE SOFTWARE (fc2)" => {
      "operatingsystem" => "IOS",
      "operatingsystemplatform" => "1841",
      "operatingsystemrelease" => "12.4(24)T4",
      "operatingsystemmajrelease" => "12.4T",
      "operatingsystemfeature" => "ADVSECURITYK9"
    },
    "Cisco IOS Software, C3750 Software (C3750-IPBASEK9-M), Version 12.2(55)SE6, RELEASE SOFTWARE (fc1)" => {
      "operatingsystem" => "IOS",
      "operatingsystemplatform" => "C3750",
      "operatingsystemrelease" => "12.2(55)SE6",
      "operatingsystemmajrelease" => "12.2SE",
      "operatingsystemfeature" => "IPBASEK9"
    },
    "Cisco IOS Software, IOS-XE Software, Catalyst 4500 L3 Switch Software (cat4500e-UNIVERSALK9-M), Version 03.04.00.SG RELEASE SOFTWARE (fc3)" => {
      "operatingsystem" => "IOS",
      "operatingsystemplatform" => "IOS-XE",
      "operatingsystemrelease" => "03.04.00.SG",
      "operatingsystemmajrelease" => "03.04.00.SG",
      "operatingsystemfeature" => "UNIVERSALK9",
      "operatingsystemxeplatform" => "4500"
    },
    "Cisco IOS Software, s72033_rp Software (s72033_rp-ADVIPSERVICESK9_WAN-M), Version 12.2(33)SXJ2, RELEASE SOFTWARE (fc4)" => {
      "operatingsystem" => "IOS",
      "operatingsystemplatform" => "s72033_rp",
      "operatingsystemrelease" => "12.2(33)SXJ2",
      "operatingsystemmajrelease" => "12.2SXJ",
      "operatingsystemfeature" => "ADVIPSERVICESK9_WAN"
    }
  }.each do |ver, expected|
    it "should parse show ver output for device software version facts" do
      @transport.stubs(:command).with("sh ver", {:cache => true, :noop => false}).returns(<<eos)
Switch>sh ver
#{ver}
Switch>
eos
      @facts.retrieve.should == expected
    end
  end

  {
    'System image file is "flash:/c3750-ipbasek9-mz.122-55.SE6/c3750-ipbasek9-mz.122-55.SE6.bin"' => {
     "system_image" => "c3750-ipbasek9-mz.122-55.SE6.bin"
    }
  }.each do |ver, expected|
    it "should parse show ver output for the system image fact" do
      @transport.stubs(:command).with("sh ver", {:cache => true, :noop => false}).returns(<<eos)
Switch>sh ver
#{ver}
Switch>
eos
      @facts.retrieve.should == expected
    end
  end

  describe "when parsing the output of 'sh ver'" do
    ["c3750", "c3750-stack", "c4506e", "c6905"].each do |switch_type|
      it "should parse the output for switchtype #{switch_type}" do
        out = File.read(File.join(File.dirname(__FILE__), "fixtures/sh_ver/#{switch_type}.out"))
        expected = YAML.load_file(File.join(File.dirname(__FILE__), "fixtures/sh_ver/#{switch_type}.yaml"))
        @transport.stubs(:command).with("sh ver", {:cache => true, :noop => false}).returns(out)
        @facts.retrieve.should == expected
      end
    end
  end
  describe "when parsing the output of 'sh inventory'" do
    ["c3750", "c3750-stack", "c4506e", "c6905"].each do |switch_type|
      it "should parse the output for switchtype #{switch_type}" do
        out = File.read(File.join(File.dirname(__FILE__), "fixtures/sh_inventory/#{switch_type}.out"))
        expected = YAML.load_file(File.join(File.dirname(__FILE__), "fixtures/sh_inventory/#{switch_type}.yaml"))
        @transport.stubs(:command).with("sh inventory", {:cache => true, :noop => false}).returns(out)
        @facts.retrieve.should == expected
      end
    end
  end
  describe "when parsing the output of 'sh interfaces summary'" do
    ["c3750", "c3750-stack", "c4506e", "c6905"].each do |switch_type|
      it "should parse the output for switchtype #{switch_type}" do
        out = File.read(File.join(File.dirname(__FILE__), "fixtures/sh_interfaces_summary/#{switch_type}.out"))
        expected = YAML.load_file(File.join(File.dirname(__FILE__), "fixtures/sh_interfaces_summary/#{switch_type}.yaml"))
        @transport.stubs(:command).with("sh interfaces summary", {:cache => true, :noop => false}).returns(out)
        @facts.retrieve.should == expected
      end
    end
  end
end
