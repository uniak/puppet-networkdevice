#! /usr/bin/env ruby
require 'spec_helper'
require 'puppet/util/network_device'
require 'puppet/util/network_device/cisco_ios/model/vrf'

describe Puppet::Util::NetworkDevice::Cisco_ios::Model::Vrf do
  before(:each) do
    @transport = mock("transport")
    @transport.stubs(:command).with('conf t', anything)
    @transport.stubs(:command).with('end', anything)
    @vrf = Puppet::Util::NetworkDevice::Cisco_ios::Model::Vrf.new(@transport, {}, { :name => 'TESTVRF12', :desc => 'TEST VRF 12', :ensure => :present })
  end

  describe 'when working with vrf params' do
    before do
      @vrf_config = <<END
!
ip vrf TEST1
 description TEST 1
 rd 10.11.12.13:123
 route-target export 123:128
 route-target export 124:128
 route-target import 123:128
!
ip vrf TESTVRF12
 description TEST VRF 12
 rd 10.11.12.15:555
 route-target export 555:128
 route-target import 555:128
 route-target import 556:128
!
ip vrf TEST3
!
END
  end

    it 'should initialize various base params' do
      @vrf.params.should_not == be_empty
    end

    it 'should set the name from the options' do
      @vrf.name.should == 'TESTVRF12'
    end

    it 'should set the scope_name on the desc param' do
      @vrf.params[:desc].scope_name.should == 'TESTVRF12'
    end

    it 'should parse value of the desc param' do
      @transport.expects(:command).with('sh run', {:cache => true, :noop => false}).returns(@vrf_config).at_least(2)

      @vrf.evaluate_new_params
      @vrf.params[:desc].value.should == "TEST VRF 12"
    end

    it 'should parse value of the rd param' do
      @transport.expects(:command).with('sh run', {:cache => true, :noop => false}).returns(@vrf_config).at_least(2)

      @vrf.evaluate_new_params
      @vrf.params[:rd].value.should == "10.11.12.15:555"
    end

    it 'should parse value of the export param' do
      @transport.expects(:command).with('sh run', {:cache => true, :noop => false}).returns(@vrf_config).at_least(2)

      @vrf.evaluate_new_params
      @vrf.params[:export].value.should == [ '555:128' ]
    end

    it 'should parse value of the import param' do
      @transport.expects(:command).with('sh run', {:cache => true, :noop => false}).returns(@vrf_config).at_least(2)

      @vrf.evaluate_new_params
      @vrf.params[:import].value.should == [ '555:128', '556:128' ]
    end

    it 'should add a vrf with default description' do
      @transport.expects(:command).with('ip vrf TESTVRF12', :prompt => /\(config-vrf\)#\s?\z/n)
      @transport.expects(:command).with('exit')
      @transport.stubs(:command).with("sh run", {:cache => true, :noop => false}).returns(@vrf_config)
      @vrf = Puppet::Util::NetworkDevice::Cisco_ios::Model::Vrf.new(@transport, {}, { :name => 'TESTVRF12', :ensure => :present })
      @vrf.evaluate_new_params
      @vrf.update({:ensure => :absent}, {:ensure => :present})
    end

    it 'should update a vrf description' do
      @transport.expects(:command).with('ip vrf TESTVRF12', :prompt => /\(config-vrf\)#\s?\z/n)
      @transport.expects(:command).with('description TEST VRF 42', :prompt => /\(config-vrf\)#\s?\z/n)
      @transport.expects(:command).with('exit')
      @transport.stubs(:command).with("sh run", {:cache => true, :noop => false}).returns(@vrf_config)
      @vrf.evaluate_new_params
      @vrf.update({:ensure => :present, :desc => 'TEST VRF 12'}, {:ensure => :present, :desc => 'TEST VRF 42'})
    end

    it 'should remove a vrf' do
      @transport.expects(:command).with('no ip vrf TESTVRF12')
      @transport.stubs(:command).with("sh run", {:cache => true, :noop => false}).returns(@vrf_config)
      @vrf.evaluate_new_params
      @vrf.update({:ensure => :present}, {:ensure => :absent})
    end

    it 'should add a vrf with a route distinguisher' do
      @transport.expects(:command).with('ip vrf NEWVRF', :prompt => /\(config-vrf\)#\s?\z/n)
      @transport.expects(:command).with('rd 10.20.30.40:128', :prompt => /\(config-vrf\)#\s?\z/n)
      @transport.expects(:command).with('exit')
      @transport.stubs(:command).with("sh run", {:cache => true, :noop => false}).returns(@vrf_config)
      @vrf = Puppet::Util::NetworkDevice::Cisco_ios::Model::Vrf.new(@transport, {}, { :name => 'NEWVRF', :ensure => :present, :rd => '10.20.30.40:128' })
      @vrf.evaluate_new_params
      @vrf.update({:ensure => :absent}, {:ensure => :present, :rd => '10.20.30.40:128'})
    end

    it 'should update a vrf route distinguisher' do
      @transport.expects(:command).with('ip vrf TESTVRF12', :prompt => /\(config-vrf\)#\s?\z/n)
      @transport.expects(:command).with('no rd 10.11.12.15:555', :prompt => /\(config-vrf\)#\s?\z/n)
      @transport.expects(:command).with('rd 10.21.31.41:1234', :prompt => /\(config-vrf\)#\s?\z/n)
      @transport.expects(:command).with('exit')
      @transport.stubs(:command).with("sh run", {:cache => true, :noop => false}).returns(@vrf_config)
      @vrf.evaluate_new_params
      @vrf.update({:ensure => :present, :rd => '10.11.12.15:555'}, {:ensure => :present, :rd => '10.21.31.41:1234'})
    end

    it 'should update the vrf import list' do
      @transport.expects(:command).with('ip vrf TESTVRF12', :prompt => /\(config-vrf\)#\s?\z/n)
      @transport.expects(:command).with('no route-target import 555:128', :prompt => /\(config-vrf\)#\s?\z/n)
      @transport.expects(:command).with('route-target import 557:128', :prompt => /\(config-vrf\)#\s?\z/n)
      @transport.expects(:command).with('exit')
      @transport.stubs(:command).with("sh run", {:cache => true, :noop => false}).returns(@vrf_config)
      @vrf.evaluate_new_params
      @vrf.update({:ensure => :present, :import => [ '555:128', '556:128' ] },
                  {:ensure => :present, :import => [ '557:128', '556:128' ]})
    end

    it 'should update the vrf export list' do
      @transport.expects(:command).with('ip vrf TESTVRF12', :prompt => /\(config-vrf\)#\s?\z/n)
      @transport.expects(:command).with('no route-target export 555:128', :prompt => /\(config-vrf\)#\s?\z/n)
      @transport.expects(:command).with('route-target export 556:128', :prompt => /\(config-vrf\)#\s?\z/n)
      @transport.expects(:command).with('route-target export 557:128', :prompt => /\(config-vrf\)#\s?\z/n)
      @transport.expects(:command).with('exit')
      @transport.stubs(:command).with("sh run", {:cache => true, :noop => false}).returns(@vrf_config)
      @vrf.evaluate_new_params
      @vrf.update({:ensure => :present, :export => [ '555:128' ] },
                  {:ensure => :present, :export => [ '556:128', '557:128' ]})
    end
  end
end
