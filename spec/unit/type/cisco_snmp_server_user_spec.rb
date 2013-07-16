#! /usr/bin/env ruby
require 'spec_helper'

describe Puppet::Type.type(:cisco_snmp_server_user) do

  it "should have a 'name' parameter'" do
    described_class.new(:name => 'foobar')[:name].should == 'foobar'
  end
  it "should be applied on device" do
    described_class.new(:name => 'foobar').must be_appliable_to_device
  end

  [:group, :type, :acl_type, :acl].each do |p|
    it "should have a #{p} property" do
      described_class.attrtype(p).should == :property
    end
  end

  describe "when validating attribute values" do
    describe "group" do
      it "should allow any valid string" do
        described_class.new(:name => 'foobar', :group => 'foo-bar')
      end

      it "should raise an exception on strings containing spaces" do
        expect { described_class.new(:name => 'foobar', :group => 'foo bar') }.to raise_error
      end
    end

    describe "type" do
      [:remote, :v1, :v2c, :v3].each do |type|
        it "should allow #{type.inspect}" do
          described_class.new(:name => 'foobar', :type => type)
        end
      end
      it "should raise an exception on everything else" do
        expect { described_class.new(:name => 'foobar', :type => :foo) }.to raise_error
      end
    end

    describe "acl_type" do
      [:std, :ipv6].each do |type|
        it "should allow #{type.inspect}" do
          described_class.new(:name => 'foobar', :acl_type => type)
        end
      end
      it "should raise an exception on everything else" do
        expect { described_class.new(:name => 'foobar', :acl_type => :foo) }.to raise_error
      end
    end

    describe "acl" do
      it "should allow any valid string" do
        described_class.new(:name => 'foobar', :acl => 'foo-bar')
      end

      it "should allow any number" do
        described_class.new(:name => 'foobar', :acl => 99)
      end

      it "should raise an exception on strings containing spaces" do
        expect { described_class.new(:name => 'foobar', :acl => 'foo bar') }.to raise_error
      end
    end

    describe "when validating all acl_type and acl together" do
      it "should allow an acl_type of :std with an :acl of 90" do
        described_class.new(:name => 'foobar', :acl_type => :std, :acl => 90)
      end
      it "should raise an exception on everyhting else for acl_type :std" do
        expect { described_class.new(:name => 'foobar', :acl_type => :std, :acl => 100) }.to raise_error
      end
    end
  end
end
