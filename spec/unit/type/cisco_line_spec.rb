#! /usr/bin/env ruby
require 'spec_helper'

describe Puppet::Type.type(:cisco_line) do

  let(:name) { "vty 10" }

  it "should have a 'name' parameter'" do
    described_class.new(:name => "vty 10")[:name].should == name
  end

  it "should be applied on device" do
    described_class.new(:name => name).must be_appliable_to_device
  end

  [:name].each do |p|
    it "should have a #{p} param" do
      described_class.attrtype(p).should == :param
    end
  end

  [:access_class, :exec_timeout, :logging, :transport].each do |p|
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
      [ 'con 0', 'con 1', 'vty 2', 'vty 10' ].each do |name|
        it "should allow '#{name}'" do
          described_class.new(:name => name)
        end
      end

      it "should raise an exception on other names" do
        expect { described_class.new(:name => "foo bar") }.to raise_error
      end
    end

    describe "access_class" do
      [:absent, 'SSH-ALLOW in', 'SSH-ALLOW out', 'blubb'].each do |access|
        it "should allow #{access.inspect}" do
          described_class.new(:name => name, :access_class => access)
        end
      end
    end

    describe "exec_timeout" do
      [:absent, 10, 100, 1000].each do |timeout|
        it "should allow #{timeout.inspect}" do
          described_class.new(:name => name, :exec_timeout => timeout)
        end
      end

      ['9', '99', '999'].each do |timeout|
        it "should allow transform #{timeout.inspect} to int" do
          described_class.new(:name => name, :exec_timeout => timeout)[:exec_timeout].should == timeout.to_i
        end
      end

      it "should raise an exception on everything else" do
        expect { described_class.new(:name => name, :exec_timeout => :test) }.to raise_error
      end
    end

    describe "logging" do
      [:absent, :synchronous].each do |logging|
        it "should allow #{logging.inspect}" do
          described_class.new(:name => name, :logging => logging)
        end
      end

      it "should raise an exception on everything else" do
        expect { described_class.new(:name => name, :logging => :foo) }.to raise_error
      end
    end

    describe "transport" do
      [:all, :none, :ssh, :telnet].each do |transport|
        it "should allow #{transport.inspect}" do
          described_class.new(:name => name, :transport => transport)
        end
      end

      it "should raise an exception on everything else" do
        expect { described_class.new(:name => name, :transport => :foo) }.to raise_error
      end
    end
  end
end
