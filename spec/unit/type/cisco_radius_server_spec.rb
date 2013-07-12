#! /usr/bin/env ruby
require 'spec_helper'

describe Puppet::Type.type(:cisco_radius_server) do
  let(:name) { '127.0.0.1' }
  it "should have a 'name' parameter'" do
    described_class.new(:name => '127.0.0.1')[:name].should == name
  end
  it "should be applied on device" do
    described_class.new(:name => name).must be_appliable_to_device
  end

  [:name].each do |p|
    it "should have a #{p} param" do
      described_class.attrtype(p).should == :param
    end
  end

  [:auth_port, :acct_port, :key_type, :key].each do |p|
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
      [ '127.0.0.1', '10.10.1.1' ].each do |name|
        it "should allow the valid IP Address '#{name}'" do
          described_class.new(:name => name)
        end
      end

      it "should raise an exception on non IP Address values" do
        expect { described_class.new(:name => "foo bar") }.to raise_error
      end
    end

    describe 'acct_port' do
      [ :absent, 1800, 18000 ].each do |val|
        it "should allow #{val.inspect}" do
          described_class.new(:name => name, :acct_port => val)
        end
      end
      it "should raise an exception on everything else" do
        expect { described_class.new(:name => name, :acct_port => 'foo bar') }.to raise_error
      end
    end

    describe 'auth_port' do
      [ :absent, 1800, 18000 ].each do |val|
        it "should allow #{val.inspect}" do
          described_class.new(:name => name, :auth_port => val)
        end
      end
      it "should raise an exception on everything else" do
        expect { described_class.new(:name => name, :auth_port => 'foo bar') }.to raise_error
      end
    end

    describe 'key_type' do
      [ :absent, 0, 7 ].each do |val|
        it "should allow #{val.inspect}" do
          described_class.new(:name => name, :key_type => val)
        end
      end
      it "should raise an exception on everything else" do
        expect { described_class.new(:name => name, :key_type => 'foo bar') }.to raise_error
      end
    end

    describe 'key' do
      it "should allow strings without spaces" do
        described_class.new(:name => name, :key => 'QERTY63446')
      end
      it "should raise an exception on everything else" do
        expect { described_class.new(:name => name, :key => 'foo bar') }.to raise_error
      end
    end
  end
end
