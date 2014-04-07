#! /usr/bin/env ruby
require 'spec_helper'

describe Puppet::Type.type(:cisco_hsrp_standby_group) do

  let(:interface_name) { 'Vlan900' }
  let(:standby_group) { '1' }
  let(:name) { "#{interface_name}/#{standby_group}" }

  it "should have a 'name' parameter'" do
    described_class.new(:name => name)[:name].should == name
  end

  it "should be applied on device" do
    described_class.new(:name => name).must be_appliable_to_device
  end

  [:name].each do |p|
    it "should have a #{p} param" do
      described_class.attrtype(p).should == :param
    end
  end

  [:ip,
   :timers,
   :authentication,
   :priority,
   :preempt,
   :preempt_delay_minimum,
   :preempt_delay_reload,
   :preempt_delay_sync
  ].each do |p|
  it "should have a #{p} property" do
      described_class.attrtype(p).should == :property
    end
  end
end
