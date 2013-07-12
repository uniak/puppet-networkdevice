require 'spec_helper'
require 'puppet/util/network_device/cisco_ios/model/scoped_value'

describe Puppet::Util::NetworkDevice::Cisco_ios::Model::ScopedValue do
  before(:each) do
    @transport = stub_everything 'transport'
    @value = Puppet::Util::NetworkDevice::Cisco_ios::Model::ScopedValue.new(:test, @transport, nil, 0)

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

  describe 'when working with a scoped value' do
    before do
      @value.scope /^(interface\s+(\S+).*?)^!/m
      @value.match /^\s*description\s+(\S+)$/
    end

    it 'should parse the right scope from txt' do
      @value.scope_name 'test1'
      @value.extract_scope(@testdata).should == "interface test1\n  description test1desc\n"
    end

    it 'should parse the value from the first scope' do
      @value.scope_name 'test1'
      @value.parse(@testdata)
      @value.value.should == 'test1desc'
    end

    it 'should parse the value from the last scope' do
      @value.scope_name 'test4'
      @value.parse(@testdata)
      @value.value.should == 'test4desc'
    end
  end

  describe 'when working with a complex scope' do
    before do
      @complex = <<END
line vty 0 4
 first
 second
line vty 5 10
 third
 fourth
!
END
      @value.scope /^(line vty (\d+ \d+)\s*\n(?:\s[^\n]*\n)*)/
      @value.scope_match do |scope, scope_name|
        matches = scope_name.match /(\d+) (\d+)/
        from = matches[1].to_i
        to = matches[2].to_i
        (from..to).collect { |vty| [scope, vty] }
      end
      @value.match /^\s*(\S+)$/
    end
    it 'should return a scope for existing values' do
      @value.scope_name 1
      @value.parse(@complex)
      @value.value.should == 'first'
    end
  end
end
