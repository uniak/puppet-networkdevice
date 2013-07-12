#! /usr/bin/env ruby
require 'spec_helper'

describe Puppet::Type.type(:cisco_user) do
  let(:name) { 'admin' }
  it "should have a 'name' parameter'" do
    described_class.new(:name => 'admin')[:name].should == name
  end
  it "should be applied on device" do
    described_class.new(:name => name).must be_appliable_to_device
  end

  [:name].each do |p|
    it "should have a #{p} param" do
      described_class.attrtype(p).should == :param
    end
  end

  [ :privilege, :password_type, :password ].each do |p|
    it "should have a #{p} property" do
      described_class.attrtype(p).should == :property
    end
  end
  describe "when validating attribute values" do
    before do
      @provider = stub 'provider', :class => described_class.defaultprovider, :clear => nil
      described_class.defaultprovider.stubs(:new).returns(@provider)
    end
    describe 'name' do
      it "should allow 'admin'" do
        described_class.new(:name => name)
      end

      it "should raise an exception on names containing spaces" do
        expect { described_class.new(:name => "foo bar") }.to raise_error
      end
    end
    describe 'privilege' do
      (0..15).each do |val|
        it "should accept a value between 0-15: #{val.inspect}" do
          described_class.new(:name => name, :privilege => val)
        end
      end
      it "should raise an exception on everything else" do
        expect { described_class.new(:name => name, :privilege => 'foo bar') }.to raise_error
      end
    end
    describe 'password_type' do
      [ :absent, 0, 7 ].each do |val|
        it "should allow #{val.inspect}" do
          described_class.new(:name => name, :password_type => val)
        end
      end
      it "should raise an exception on everything else" do
        expect { described_class.new(:name => name, :password_type => 'foo bar') }.to raise_error
      end
    end
    describe 'password' do
      it "should allow strings without spaces" do
        described_class.new(:name => name, :password => 'QERTY63446')
      end
      it "should raise an exception on everything else" do
        expect { described_class.new(:name => name, :password => 'foo bar') }.to raise_error
      end
    end
  end
end
