#! /usr/bin/env ruby
require 'spec_helper'

describe Puppet::Type.type(:cisco_snmp_server_group) do

  it "should have a 'name' parameter'" do
    described_class.new(:name => 'foobar')[:name].should == 'foobar'
  end
  it "should be applied on device" do
    described_class.new(:name => "foobar").must be_appliable_to_device
  end

  [:model, :access, :context, :notify_view, :read_view, :write_view].each do |p|
    it "should have a #{p} property" do
      described_class.attrtype(p).should == :property
    end
  end

  describe "when validating attribute values" do
    describe "model" do
      [:v1, :v2c, :v3].each do |mod|
        it "should allow #{mod.inspect}" do
          described_class.new(:name => 'foobar', :model => mod)
        end
      end

      it "should raise an exception on anything else" do
        expect { described_class.new(:name => 'foobar', :model => :v4) }.to raise_error
      end
    end

    describe "access" do
      it "should allow any valid string" do
        described_class.new(:name => 'foobar', :access => 'foo-bar')
      end

      it "should allow any number from 1-99" do
        described_class.new(:name => 'foobar', :access => 99)
      end

      it "should raise an exception on strings containing spaces" do
        expect { described_class.new(:name => 'foobar', :access => 'foo bar') }.to raise_error
      end

      it "should raise an exception on invalid numbers" do
        expect { described_class.new(:name => 'foobar', :access => 100) }.to raise_error
      end
    end

    describe "context" do
      it "should allow any valid string" do
        described_class.new(:name => 'foobar', :access => 'foo-bar')
      end
      it "should raise an exception on strings containing spaces" do
        expect { described_class.new(:name => 'foobar', :access => 'foo bar') }.to raise_error
      end
    end

    describe "notify_view" do
      it "should allow any valid string" do
        described_class.new(:name => 'foobar', :notify_view => 'foo-bar')
      end
      it "should raise an exception on strings containing spaces" do
        expect { described_class.new(:name => 'foobar', :notify_view => 'foo bar') }.to raise_error
      end
    end

    describe "read_view" do
      it "should allow any valid string" do
        described_class.new(:name => 'foobar', :read_view => 'foo-bar')
      end
      it "should raise an exception on strings containing spaces" do
        expect { described_class.new(:name => 'foobar', :read_view => 'foo bar') }.to raise_error
      end
    end

    describe "write_view" do
      it "should allow any valid string" do
        described_class.new(:name => 'foobar', :write_view => 'foo-bar')
      end
      it "should raise an exception on strings containing spaces" do
        expect { described_class.new(:name => 'foobar', :write_view => 'foo bar') }.to raise_error
      end
    end
  end
end
