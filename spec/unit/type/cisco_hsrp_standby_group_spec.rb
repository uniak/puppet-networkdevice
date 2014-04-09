#! /usr/bin/env ruby
require 'spec_helper'

describe Puppet::Type.type(:cisco_hsrp_standby_group) do

  let(:parent_interface) { 'Vlan900' }
  let(:standby_group) { '1' }
  let(:name) { "#{parent_interface}/#{standby_group}" }

  it "should have a 'name' parameter'" do
    described_class.new(:name => name)[:name].should == name
  end

  it "should be applied on device" do
    described_class.new(:name => name).must be_appliable_to_device
  end

  [:name, :parent_interface, :standby_group].each do |p|
    it "should have a #{p} param" do
      described_class.attrtype(p).should == :param
    end
  end

  describe 'when initialising' do
    it 'should accept and parse a single title' do
      group = described_class.new(:name => name)
      group.name.should == name
      group[:parent_interface].should == parent_interface
      group[:standby_group].should == standby_group
    end
    it 'should accept separate namevar specifications' do
      group = described_class.new(:name => 'The Thing', :parent_interface => parent_interface, :standby_group => standby_group)
      group.title.should == 'The Thing'
      group.name.should == name
      group[:parent_interface].should == parent_interface
      group[:standby_group].should == standby_group
    end
    it 'should apply group overrides to a parsed title' do
      group = described_class.new(:name => name, :standby_group => '4')
      group.name.should == "#{parent_interface}/4"
      group[:parent_interface].should == parent_interface
      group[:standby_group].should == '4'
    end
    it 'should apply interface overrides to a parsed title' do
      group = described_class.new(:name => name, :parent_interface => 'Vlan888')
      group.name.should == "Vlan888/#{standby_group}"
      group[:parent_interface].should == 'Vlan888'
      group[:standby_group].should == standby_group
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
