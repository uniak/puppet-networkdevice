require 'puppet/util/network_device/cisco_ios'
require 'puppet/util/network_device/value_helper'

class Puppet::Util::NetworkDevice::Cisco_ios::Fact
  attr_accessor :name, :idx, :value, :evaluated
  extend Puppet::Util::NetworkDevice::ValueHelper

  def initialize(name, transport, facts = nil, idx = 0, &block)
    @name = name
    @idx = idx
    @evaluated = false
    @downcase = false
    self.instance_eval(&block)
  end

  define_value_method [:cmd, :match, :add, :remove, :before, :after, :match_param, :required, :downcase]

  def parse(txt)
    if self.match.is_a?(Proc)
      self.value = self.match.call(txt)
    else
      self.value = txt.scan(self.match).flatten[self.idx]
    end
    self.evaluated = true
    self.value = self.value.downcase if downcase and self.value
    raise Puppet::Error, "Fact: #{self.name} is required but didn't evaluate to a proper Value" if self.required == true && (self.value.nil? || self.value.to_s.empty?)
  end

  def ios_major_version(version)
    # TODO: Review
    return if version.nil?
    version.gsub(/^(\d+)\.(\d+)\(.+\)([A-Z]+)([\da-z]+)?/, '\1.\2\3')
  end

  def uptime_to_seconds(uptime)
    # TODO: Review
    return if uptime.nil?
    captures = (uptime.match /^(?:(\d+) years?,)?\s*(?:(\d+) weeks?,)?\s*(?:(\d+) days?,)?\s*(?:(\d+) hours?,)?\s*(\d+) minutes?$/).captures
    seconds = captures.zip([31536000, 604800, 86400, 3600, 60]).inject(0) do |total, (x,y)|
      total + (x.nil? ? 0 : x.to_i * y)
    end
  end

  def canonicalize_hardwaremodel(hardwaremodel)
    hardwaremodels = {
      'c4500' => %w{WS-C4506-E WS-C4507R+E},
      'c3750' => %w{WS-C3750-24TS WS-C3750-24PS WS-C3750G-24TS-1U WS-C3750G-24PS WS-C3750-24TS-S WS-C3750-24P WS-C3750-48TS WS-C3750G-24PS-S WS-C3750E-24PD},
      'c3560' => %w{WS-C3560-12PC-S},
      'c2960' => %w{WS-C2960G-48TC-L WS-C2960-24TC-L WS-C2960G-24TC-L},
      'c2950' => %w{WS-C2950T-24},
      'c2924' => %w{WS-C2924C-XL},
      'c6509' => %w{WS-C6509-E},
      'c1841' => %w{1841},
      'c877' => %w{877}
    }
    hardwaremodels.each do |k,v|
      return k if v.find {|model| hardwaremodel == model}
    end
    hardwaremodel
  end
end
