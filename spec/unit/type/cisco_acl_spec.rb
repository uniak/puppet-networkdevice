#! /usr/bin/env ruby
require 'spec_helper'

describe Puppet::Type.type(:cisco_acl) do

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

  [:type, :acl].each do |p|
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

    describe "type" do
      [:standard].each do |type|
        it "should allow #{type.inspect}" do
          described_class.new(:name => name, :type => type)
        end
      end

      it "should raise an exception on everything else" do
        expect { described_class.new(:name => name, :type => :test) }.to raise_error
      end
    end

    describe "acl" do
      it "should allow hostnames" do
        described_class.new(:name => name, :acl => ["permit radius.example.com"])[:acl].should == [ "permit radius.example.com" ]
      end

      it "should allow IPv4 addresses" do
        described_class.new(:name => name, :acl => [ "deny 10.0.12.0 0.255.0.255"])[:acl].should == [ "deny 10.0.12.0 0.255.0.255" ]
      end

      it "should raise an exception on everything else" do
        expect { described_class.new(:name => name, :acl => "foo bar") }.to raise_error
      end
    end
  end
end
