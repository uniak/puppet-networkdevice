#! /usr/bin/env ruby
require 'spec_helper'

describe Puppet::Type.type(:cisco_snmp_server_view_ios) do

  it "should have a 'name' parameter'" do
    described_class.new(:name => 'foobar')[:name].should == 'foobar'
  end
  it "should be applied on device" do
    described_class.new(:name => 'foobar').must be_appliable_to_device
  end

  [:excluded_mibs, :included_mibs].each do |p|
    it "should have a #{p} property" do
      described_class.attrtype(p).should == :property
    end
  end

  describe "when validating attribute values" do
    describe "excluded_mibs" do
      it "should allow any valid string" do
        described_class.new(:name => 'foobar', :excluded_mibs => 'foo-bar')
      end

      it "should allow arrays" do
        described_class.new(:name => 'foobar', :excluded_mibs => ['system', 'cisco'])
      end

      it "should raise an exception on strings containing spaces" do
        expect { described_class.new(:name => 'foobar', :excluded_mibs => 'foo bar') }.to raise_error
      end
    end

    describe "included_mibs" do
      it "should allow any valid string" do
        described_class.new(:name => 'foobar', :included_mibs => 'foo-bar')
      end

      it "should allow arrays" do
        described_class.new(:name => 'foobar', :included_mibs => ['system', 'cisco'])
      end

      it "should raise an exception on strings containing spaces" do
        expect { described_class.new(:name => 'foobar', :included_mibs => 'foo bar') }.to raise_error
      end
    end
  end
end
