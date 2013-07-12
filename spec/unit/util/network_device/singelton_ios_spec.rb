require 'spec_helper'
require 'puppet/util/network_device/singelton_ios'
require 'puppet/util/network_device/cisco_ios/device'

describe Puppet::Util::NetworkDevice::Singelton_ios do
  before(:each) do
    @device = Puppet::Util::NetworkDevice::Cisco_ios::Device.new('sshios://127.0.0.1:22/')
    @device.stubs(:init).returns(@device)
  end

  after(:each) do
    Puppet::Util::NetworkDevice::Singelton_ios.clear
  end

  describe 'when initializing the remote network device singleton' do
    it 'should create a network device instance' do
      Puppet::Util::NetworkDevice::Cisco_ios::Device.expects(:new).returns(@device)
      Puppet::Util::NetworkDevice::Singelton_ios.lookup('sshios://127.0.0.1:22/').should == @device
    end

    it 'should cache the network device' do
      Puppet::Util::NetworkDevice::Cisco_ios::Device.expects(:new).times(1).returns(@device)
      Puppet::Util::NetworkDevice::Singelton_ios.lookup('sshios://127.0.0.1:22/').should == @device
      Puppet::Util::NetworkDevice::Singelton_ios.lookup('sshios://127.0.0.1:22/').should == @device
    end
  end
end
