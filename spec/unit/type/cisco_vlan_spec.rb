#! /usr/bin/env ruby
require 'spec_helper'

describe Puppet::Type.type(:cisco_vlan) do
  let(:name) { '1100' }
  it "should have a 'name' parameter'" do
    described_class.new(:name => '1100')[:name].should == name
  end
  it "should be applied on device" do
    described_class.new(:name => name).must be_appliable_to_device
  end

  [:name].each do |p|
    it "should have a #{p} param" do
      described_class.attrtype(p).should == :param
    end
  end

  [ :desc ].each do |p|
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
      it "should allow only Integers '1100'" do
        described_class.new(:name => name)
      end

      it "should raise an exception on everything else" do
        expect { described_class.new(:name => "foo bar") }.to raise_error
      end
    end
    describe 'desc' do
      it 'should allow strings without spaces' do
        described_class.new(:name => name, :desc => 'foobar')
      end
      it "should raise an exception on strings containing spaces" do
        expect { described_class.new(:name => name, :desc => 'foo bar') }.to raise_error
      end
    end
  end
end
