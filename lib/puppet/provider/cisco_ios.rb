require 'puppet/util/network_device/singelton_ios'
require 'puppet/provider/network_device'

# This is the base Class of all prefetched cisco device providers
class Puppet::Provider::Cisco_ios < Puppet::Provider::NetworkDevice
  def self.device(url)
    Puppet::Util::NetworkDevice::Singelton_ios.lookup(url)
  end

  def self.prefetch(resources)
    resources.each do |name, resource|
      device = Puppet::Util::NetworkDevice.current || device(resource[:device_url])
      if result = lookup(device, name)
        resource.provider = new(device, result)
      else
        resource.provider = new(device, :ensure => :absent)
      end
    end
  end
end
