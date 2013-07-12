#! /usr/bin/env ruby
require 'spec_helper'

describe Puppet::Type.type(:cisco_snmp_server_trap_ios) do

  let(:name) { :running }

  it "should have a 'name' parameter'" do
    described_class.new(:name => :running)[:name].should == :running
  end
  it "should be applied on device" do
    described_class.new(:name => :running).must be_appliable_to_device
  end

  [:authentication_acl_failure, :authentication_unknown_context, :authentication_vrf,
   :link_ietf, :retry, :timeout].each do |p|
    it "should have a #{p} property" do
      described_class.attrtype(p).should == :property
    end
  end

  describe "when validating attribute values" do
    describe "authentication_acl_failure" do
      it_behaves_like "ensureable" do
        let(:prop) { :authentication_acl_failure }
      end
    end

    describe "authentication_unknown_context" do
      it_behaves_like "ensureable" do
        let(:prop) { :authentication_unknown_context }
      end
    end

    describe "authentication_vrf" do
      it_behaves_like "ensureable" do
        let(:prop) { :authentication_vrf }
      end
    end

    describe "link_ietf" do
      it_behaves_like "ensureable" do
        let(:prop) { :link_ietf }
      end
    end

    describe "retry" do
      it "should allow any number between 0-10" do
        described_class.new(:name => :running, :retry => 5)
      end
      it "should raise an exception on an invalid value of -1" do
        expect { described_class.new(:name => :running, :inform_retries => -1) }.to raise_error
      end
      it "should raise an exception on an invalid value of 11" do
        expect { described_class.new(:name => :running, :inform_retries => 11) }.to raise_error
      end
    end

    describe "timeout" do
      it "should allow any number between 1-1000" do
        described_class.new(:name => :running, :timeout => 50)
      end
      it "should raise an exception on an invalid value of 0" do
        expect { described_class.new(:name => :running, :timeout => 0) }.to raise_error
      end
      it "should raise an exception on an invalid value of 1001" do
        expect { described_class.new(:name => :running, :timeout => 1001) }.to raise_error
      end
    end
  end
end
