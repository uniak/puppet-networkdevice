require 'spec_helper'
require 'puppet/util/network_device/cisco_ios/model/interface'
require 'puppet/util/network_device/cisco_ios/model/model_value'

describe Puppet::Util::NetworkDevice::Cisco_ios::Model::ModelValue do
  before(:each) do
    @transport = stub_everything 'transport'
    @value = Puppet::Util::NetworkDevice::Cisco_ios::Model::ModelValue.new(:test, @transport, nil, 0)

    @testdata = <<END
interface test1
  description test1desc
!
interface test2
  description test2desc
!
interface test3
  description test3desc
!
interface test4
  description test4desc
!
END
  end

  describe 'when working with a model value' do
    before do
      @value.match /^interface\s+(\S+)$/
      @value.model Puppet::Util::NetworkDevice::Cisco_ios::Model::Interface
    end

    it 'should return all instances' do
      @value.parse(@testdata)

      @value.value.should_not be_nil
      @value.value.count.should == 4
      @value.value.each do |v|
        v.should be_a Puppet::Util::NetworkDevice::Cisco_ios::Model::Interface
      end
      @value.value.should be_any { |v| v.name == 'test1' }
      @value.value.should be_any { |v| v.name == 'test2' }
      @value.value.should be_any { |v| v.name == 'test3' }
      @value.value.should be_any { |v| v.name == 'test4' }
    end
  end
end
