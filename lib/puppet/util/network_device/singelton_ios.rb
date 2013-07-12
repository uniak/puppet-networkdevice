require 'puppet/util/network_device/cisco_ios/device'

class Puppet::Util::NetworkDevice::Singelton_ios
  def self.lookup(url)
    @map ||= {}
    return @map[url] if @map[url]
    @map[url] = Puppet::Util::NetworkDevice::Cisco_ios::Device.new(url).init
    return @map[url]
  end

  def self.clear
    @map.clear
  end
end
