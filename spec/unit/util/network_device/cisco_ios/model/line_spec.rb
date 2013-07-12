#! /usr/bin/env ruby
require 'spec_helper'
require 'puppet/util/network_device'
require 'puppet/util/network_device/cisco_ios/model/line'

describe Puppet::Util::NetworkDevice::Cisco_ios::Model::Line do
  before(:each) do
    @transport = stub_everything "transport"
    @line = Puppet::Util::NetworkDevice::Cisco_ios::Model::Line.new(@transport, {}, { :name => 'vty 1', :ensure => :present })
  end

  describe 'when working with line params' do
    before do
      @line_config = <<END
line con 0
 logging synchronous
line vty 0 4
 access-class SSH-ALLOW in
 exec-timeout 60 0
 logging synchronous
 transport input ssh
line vty 5 15
 access-class SSH-ALLOW in
 exec-timeout 60 0
 logging synchronous
 transport input ssh
!
END
    end

    it 'should initialize various base params' do
      @line.params.should_not == be_empty
    end

    it 'should set the name from the options' do
      @line.name.should == 'vty 1'
    end

    it 'should set the scope_name on the logging param' do
      @line.params[:logging].scope_name.should == 'vty 1'
    end

    it 'should parse the access-class param' do
      @transport.stubs(:command).with('sh run', {:cache => true, :noop => false}).returns(@line_config)
      @line.evaluate_new_params
      @line.params[:access_class].value.should == 'SSH-ALLOW in'
    end

    it 'should parse the exec-timeout param' do
      @transport.stubs(:command).with('sh run', {:cache => true, :noop => false}).returns(@line_config)
      @line.evaluate_new_params
      @line.params[:exec_timeout].value.should == 60 * 60
    end

    it 'should parse the logging param' do
      @transport.stubs(:command).with('sh run', {:cache => true, :noop => false}).returns(@line_config)
      @line.evaluate_new_params
      @line.params[:logging].value.should == "synchronous"
    end

    it 'should parse the transport param' do
      @transport.stubs(:command).with('sh run', {:cache => true, :noop => false}).returns(@line_config)
      @line.evaluate_new_params
      @line.params[:transport].value.should == "ssh"
    end

    it 'should not enter line configuration mode if nothings changed' do
      @transport.expects(:command).with('line vty 1', {:cache => true, :noop => false}).never
      @line.evaluate_new_params
      @line.update()
    end

    it 'should update the value' do
      @transport.expects(:command).with('exec-timeout 120 30')
      @transport.stubs(:command).with('sh run', {:cache => true, :noop => false}).returns(@line_config)
      @line.evaluate_new_params
      @line.update({:ensure => :present, :exec_timeout => 60*60}, {:ensure => :present, :exec_timeout => 120*60 + 30})
    end

    it 'should remove the value' do
      @transport.expects(:command).with('no exec-timeout').once
      @transport.stubs(:command).with('sh run', {:cache => true, :noop => false}).returns(@line_config)
      @line.evaluate_new_params
      @line.update({:ensure => :present, :exec_timeout => 60}, {:ensure => :present, :exec_timeout => :absent})
    end
  end
end
