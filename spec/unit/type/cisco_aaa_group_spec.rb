#! /usr/bin/env ruby
require 'spec_helper'

describe Puppet::Type.type(:cisco_aaa_group) do

  let(:name) { "NETWORK" }

  it "should have a 'name' parameter'" do
    described_class.new(:name => "NETWORK")[:name].should == name
  end

  it "should have a 'device_url' parameter'" do
    described_class.new(:name => name, :device_url => :device)[:device_url].should == :device
  end

  it "should be applied on device" do
    described_class.new(:name => name).must be_appliable_to_device
  end

  [:name, :device_url].each do |p|
    it "should have a #{p} param" do
      described_class.attrtype(p).should == :param
    end
  end

  [:protocol, :server, :auth_port, :acct_port, :local_authentication,
    :local_authorization
  ].each do |p|
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

      it "should raise an exception on names containing spaces" do
        expect { described_class.new(:name => "foo bar") }.to raise_error
      end
    end

    describe "protocol" do
      [:radius, :tacacs].each do |protocol|
        it "should allow #{protocol.inspect}" do
          described_class.new(:name => name, :protocol => protocol)
        end

      end

      it "should raise an exception on everything else" do
        expect { described_class.new(:name => name, :protocol => :test) }.to raise_error
      end
    end

    describe "server" do
      it "should allow :absent" do
        described_class.new(:name => name, :server => :absent)[:server].should == :absent
      end

      it "should allow hostnames" do
        described_class.new(:name => name, :server => "radius.example.com")[:server].should == "radius.example.com"
      end

      it "should allow IPv4 addresses" do
        described_class.new(:name => name, :server => "10.11.12.13")[:server].should == "10.11.12.13"
      end

      it "should raise an exception on everything else" do
        expect { described_class.new(:name => name, :server => "foo bar") }.to raise_error
      end
    end

    [:acct_port, :auth_port].each do |prop|
      describe prop do
        it "should allow numbers" do
          described_class.new(:name => name, prop => 1234)[prop].should == 1234
        end

        it "should raise an exception on everything else" do
          expect { described_class.new(:name => name, prop => "foobar") }.to raise_error
        end
      end
    end

    [:local_authentication, :local_authorization].each do |prop|
      describe prop do
        it "should allow true" do
          described_class.new(:name => name, prop => true)[prop].should == :true
        end

        it "should allow false" do
          described_class.new(:name => name, prop => false)[prop].should == :false
        end

        it "should raise an exception on everything else" do
          expect { described_class.new(:name => name, prop => "foobar") }.to raise_error
        end
      end
    end
  end
end
