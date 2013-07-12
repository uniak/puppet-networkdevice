#! /usr/bin/env ruby
require 'spec_helper'

describe Puppet::Type.type(:cisco_archive) do
  let(:name) { 'running' }

  it "should have a 'name' parameter'" do
    described_class.new(:name => 'running')[:name].should == :running
  end

  it "should be applied on device" do
    described_class.new(:name => name).must be_appliable_to_device
  end

  [:name].each do |p|
    it "should have a #{p} param" do
      described_class.attrtype(p).should == :param
    end
  end

  [ :path, :write_memory, :time_period ].each do |p|
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
      it "should allow 'running'" do
        described_class.new(:name => name)
      end

      it "should raise an exception on everything else" do
        expect { described_class.new(:name => "foo bar") }.to raise_error
      end
    end

    describe 'path' do
      it "should allow strings without spaces" do
        described_class.new(:name => name, :path => 'foobar')
      end

      it "should raise an exception on everything else" do
        expect { described_class.new(:name => name, :path => 'foo bar') }.to raise_error
      end
    end

    describe 'write_memory' do
      it_behaves_like "ensureable" do
        let(:prop) { :write_memory }
      end
    end

    describe 'time_period' do
      [ 1, 525600 ].each do |val|
        it "should allow the value #{val.inspect}" do
          described_class.new(:name => name, :time_period => val)
        end
      end

      it "should raise an exception on non Integer values" do
        expect { described_class.new(:name => name, :time_period => 'foobar') }.to raise_error
      end

      [ 0, 525601 ].each do |val|
        it "should raise an exception on the invalid value #{val.inspect}" do
        expect { described_class.new(:name => name, :time_period => val) }.to raise_error
        end
      end
    end
  end
end
