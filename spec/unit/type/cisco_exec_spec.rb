#! /usr/bin/env ruby
require 'spec_helper'

describe Puppet::Type.type(:cisco_exec) do
  let(:name) { 'cmd' }

  it "should have a 'name' parameter'" do
    described_class.new(:name => 'cmd')[:name].should == 'cmd'
  end

  it "should be applied on device" do
    described_class.new(:name => name).must be_appliable_to_device
  end

  [ :name, :command, :context, :refreshonly ].each do |p|
    it "should have a #{p} param" do
      described_class.attrtype(p).should == :param
    end
  end

  [ :returns ].each do |p|
    it "should have a #{p} property" do
      described_class.attrtype(p).should == :property
    end
  end

  describe "when validating attribute values" do
    before do
      @provider = stub 'provider', :class => described_class.defaultprovider, :clear => nil
      described_class.defaultprovider.stubs(:new).returns(@provider)
    end

    describe 'context' do
      [ :exec, :conf ].each do |con|
        it "should allow the value #{con.inspect}" do
          described_class.new(:name => name, :context => con)
        end
      end

      it "should raise an exception on everything else" do
        expect { described_class.new(:name => name, :context => :foobar) }.to raise_error
      end
    end

    describe 'refreshonly' do
      [ :true, :false ].each do |val|
        it "should allow the value #{val.inspect}" do
          described_class.new(:name => name, :refreshonly => val)
        end
      end

      it "should raise an exception on everything else" do
        expect { described_class.new(:name => name, :refreshonly => :foobar) }.to raise_error
      end
    end

  end
end
