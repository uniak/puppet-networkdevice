#! /usr/bin/env ruby
require 'spec_helper'
require 'puppet/util/network_device'
require 'puppet/util/network_device/cisco_ios/model/archive'

describe Puppet::Util::NetworkDevice::Cisco_ios::Model::Archive do
  before(:each) do
    @transport = stub_everything 'transport'
    @archive = described_class.new(@transport, {}, {:name => :running})
  end

  describe 'when working with snmp_host params' do
    before do
      @archive_config = <<EOF
!
archive
 path tftp://127.0.0.1/archive/foo.bar
 write-memory
 time-period 15
asdf
EOF
    end

    it 'should initialize various base params' do
      @archive.params.should_not == be_empty
    end

    it 'should set the name from the options' do
      @archive.name.should == :running
    end

    {:path => 'tftp://127.0.0.1/archive/foo.bar',
     :write_memory => :present,
     :time_period => '15'}.each do |k, v|
      it "should parse the #{k} param" do
        @transport.stubs(:command).with('sh run', {:cache => true, :noop => false}).returns(@archive_config)
        @archive.evaluate_new_params
        @archive.params[k].value.should == v
      end
    end

    it 'should enter the archive configuration if something is changed' do
      @transport.expects(:command).with('archive', anything)
      @transport.expects(:command).with('exit')
      @transport.stubs(:command).with('sh run', {:cache => true, :noop => false}).returns(@archive_config)
      @archive.evaluate_new_params
      @archive.update({:write_memory => :present},
                      {:write_memory => :absent})
    end

    it 'should not enter the archive configuration if nothing is changed' do
      @transport.expects(:command).never
      @transport.stubs(:command).with('sh run', {:cache => true, :noop => false}).returns(@archive_config)
      @archive.evaluate_new_params
      @archive.update({:write_memory => :present},
                      {:write_memory => :present})
    end

    it 'should update the value' do
      @transport.expects(:command).with('no path tftp://127.0.0.1/archive/foo.bar')
      @transport.expects(:command).with('path tftp://127.0.0.1/archive/foo')
      @transport.stubs(:command).with('sh run', {:cache => true, :noop => false}).returns(@archive_config)
      @archive.evaluate_new_params
      @archive.update({:path => 'tftp://127.0.0.1/archive/foo.bar'},
                      {:path => 'tftp://127.0.0.1/archive/foo'})
    end

    it 'should remove the value' do
      @transport.expects(:command).with('no write-memory')
      @transport.stubs(:command).with('sh run', {:cache => true, :noop => false}).returns(@archive_config)
      @archive.evaluate_new_params
      @archive.update({:write_memory => :present},
                      {:write_memory => :absent})
    end

    it 'should add the value' do
      @transport.expects(:command).with('write-memory')
      @transport.stubs(:command).with('sh run', {:cache => true, :noop => false}).returns(@archive_config)
      @archive.evaluate_new_params
      @archive.update({:write_memory => :absent},
                      {:write_memory => :present})
    end
  end
end
