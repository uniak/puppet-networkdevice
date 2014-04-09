require 'puppet/util/network_device/cisco_ios/model'
require 'puppet/util/network_device/cisco_ios/model/generic_value'
require 'puppet/util/monkey_patches_ios'

class Puppet::Util::NetworkDevice::Cisco_ios::Model::ModelValue < Puppet::Util::NetworkDevice::Cisco_ios::Model::GenericValue

  def model(*args, &block)
    return @model if args.empty? && block.nil?
    @model = (block.nil? ? args.first : block)
  end

  def parse(txt)
    if self.match.is_a?(Proc)
      self.value = self.match.call(txt)
    else
      self.value = txt.scan(self.match).flatten.collect { |name| model.new(@transport, @facts, { :name => name } ) }
    end
    self.value ||= []
    self.evaluated = true
  end

  def update(transport, old_value)
  end
  
  def new_model(*args)
    model.new(@transport, @facts, Hash[*args])
  end
end
