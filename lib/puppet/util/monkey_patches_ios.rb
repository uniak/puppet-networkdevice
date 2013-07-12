require 'puppet/util'
module Puppet::Util::MonkeyPatchesIos
end

# This is here so we can make proper use of ipaddr in arrays on 1.8.7
if RUBY_VERSION == '1.8.7'
  require 'ipaddr'
  class IPAddr
    def eql?(other)
      return self.class == other.class && self.hash == other.hash && self == other
    end

    def hash
      return ([@addr, @mask_addr].hash << 1) | (ipv4? ? 0 : 1)
    end
  end
end
