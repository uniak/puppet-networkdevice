#! /usr/bin/env ruby
require 'spec_helper'

describe Puppet::Type.type(:cisco_snmp_server_community_ios) do

  it "should have a 'name' parameter'" do
    described_class.new(:name => 'foobar')[:name].should == 'foobar'
  end
  it "should be applied on device" do
    described_class.new(:name => "foobar").must be_appliable_to_device
  end

  [:perm, :acl, :view].each do |p|
    it "should have a #{p} property" do
      described_class.attrtype(p).should == :property
    end
  end

  describe "when validating attribute values" do
    before do
      @provider = stub 'provider', :class => described_class.defaultprovider, :clear => nil
      described_class.defaultprovider.stubs(:new).returns(@provider)
    end

    describe "type" do
      it "should allow :ro" do
        described_class.new(:name => 'foobar', :perm => :ro)
      end

      it "should allow :rw" do
        described_class.new(:name => 'foobar', :perm => :rw)
      end

      it "should raise an exception on everyhting else" do
        expect { described_class.new(:name => 'foobar', :perm => "foobar") }.to raise_error
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

    describe "view" do
      it "should allow any valid string" do
        described_class.new(:name => 'foobar', :view => 'foo-bar')
      end

      it "should raise an exception on strings containing spaces" do
        expect { described_class.new(:name => 'foobar', :view => 'foo bar') }.to raise_error
      end
    end

    describe "when validating all acl_type and acl together" do
      it "should allow an acl_type of :std with an :acl of 90" do
        described_class.new(:name => 'foobar', :acl_type => :std, :acl => 90)
      end
      it "should raise an exception on everyhting else for acl_type :std" do
        expect { described_class.new(:name => 'foobar', :acl_type => :std, :acl => 100) }.to raise_error
      end

      it "should allow an acl_type of :ext with an :acl of 90" do
        described_class.new(:name => 'foobar', :acl_type => :ext, :acl => 1400)
      end
      it "should raise an exception on everyhting else for acl_type :ext" do
        expect { described_class.new(:name => 'foobar', :acl_type => :ext, :acl => 2000) }.to raise_error
      end
    end
  end
end
