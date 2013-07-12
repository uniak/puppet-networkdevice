require 'spec_helper'
require 'puppet/util/network_device/cisco_ios/model/generic_value'

describe Puppet::Util::NetworkDevice::Cisco_ios::Model::GenericValue do
  before(:each) do
    @transport = stub_everything 'transport'
    @switch = Puppet::Util::NetworkDevice::Cisco_ios::Model::GenericValue.new(:test, @transport, nil, 0)
  end

  describe 'when working with a generic value' do
    it 'should parse the value' do
      @switch.match /^hostname\s+(\S+)$/
      @switch.parse('hostname test0r')
      @switch.value.should == 'test0r'
    end
  end
end
