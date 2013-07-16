#! /usr/bin/env ruby
require 'spec_helper'

describe Puppet::Type.type(:cisco_snmp_server_host) do

  it "should have a 'name' parameter'" do
    described_class.new(:name => '127.0.0.1')[:name].should == '127.0.0.1'
  end
  it "should be applied on device" do
    described_class.new(:name => "127.0.0.1").must be_appliable_to_device
  end

  [:community, :udp_port].each do |p|
    it "should have a #{p} property" do
      described_class.attrtype(p).should == :property
    end
  end

  it 'should autorequire the community that is used' do
    catalog = Puppet::Resource::Catalog.new
    community = Puppet::Type.type(:cisco_snmp_server_community).new(:name => 'foobar')
    host = described_class.new(:name => '127.0.0.1', :community => 'foobar')
    catalog.add_resource community
    catalog.add_resource host
    reqs = host.autorequire
    reqs.size.should eq 1
    reqs[0].source.must eq community
    reqs[0].target.must eq host
  end

  it 'should not autorequire the community if it is not managed' do
    catalog = Puppet::Resource::Catalog.new
    host = described_class.new(:name => '127.0.0.1', :community => 'foobar')
    catalog.add_resource host
    reqs = host.autorequire
    reqs.size.should eq 0
  end


  describe "when validating attribute values" do

    describe "name" do
      it "should allow a valid ip address" do
        described_class.new(:name => '127.0.0.1')
      end
      it "should allow a valid ipv6 address" do
        described_class.new(:name => '::1')
      end
      it "should allow any valid http url" do
        described_class.new(:name => 'http://localhost:444/foobar')
      end
      it "should raise an exception on anything else" do
        expect { described_class.new(:name => 'foo.bar') }.to raise_error
      end
    end

    describe "community" do
      it "should allow any valid string" do
        described_class.new(:name => '127.0.0.1', :community => 'foo-bar')
      end
      it "should raise an exception on strings containing spaces" do
        expect { described_class.new(:name => '127.0.0.1', :community => 'foo bar') }.to raise_error
      end
    end

#    describe "informs" do
#      it "should allow a valid trap" do
#        described_class.new(:name => '127.0.0.1', :informs => :cpu)
#      end
#      it "should allow valid arrays" do
#        described_class.new(:name => '127.0.0.1', :informs => [:cpu, :config, :dot1x])
#      end
#      it "should raise an exception on strings containing spaces" do
#        expect { described_class.new(:name => '127.0.0.1', :informs => 'foo bar') }.to raise_error
#      end
#    end
#
#    describe "traps" do
#      it "should allow a valid trap" do
#        described_class.new(:name => '127.0.0.1', :traps => :cpu)
#      end
#      it "should allow valid arrays" do
#        described_class.new(:name => '127.0.0.1', :traps => [:cpu, :config, :dot1x])
#      end
#      it "should raise an exception on strings containing spaces" do
#        expect { described_class.new(:name => '127.0.0.1', :traps => 'foo bar') }.to raise_error
#      end
#    end
#
#    describe "version" do
#      [:v1, :v2c, :v3].each do |mod|
#        it "should allow #{mod.inspect}" do
#          described_class.new(:name => '127.0.0.1', :version => mod)
#        end
#      end
#
#      it "should raise an exception on anything else" do
#        expect { described_class.new(:name => '127.0.0.1', :version => :v4) }.to raise_error
#      end
#    end
#
#    describe "vrf" do
#      it "should allow any valid string" do
#        described_class.new(:name => '127.0.0.1', :vrf => 'foo-bar')
#      end
#      it "should raise an exception on strings containing spaces" do
#        expect { described_class.new(:name => '127.0.0.1', :vrf => 'foo bar') }.to raise_error
#      end
#    end

    describe "udp_port" do
      it "should allow any number between 0-65535" do
        described_class.new(:name => '127.0.0.1', :udp_port => 162)
      end
      it "should raise an exception on an invalid value of -1" do
        expect { described_class.new(:name => '127.0.0.1', :udp_port => -1) }.to raise_error
      end
      it "should raise an exception on an invalid value of 65536" do
        expect { described_class.new(:name => '127.0.0.1', :udp_port => 65536) }.to raise_error
      end
    end
  end

end
