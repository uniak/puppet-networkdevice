require 'tsort'

class Puppet::Util::NetworkDevice::Sorter

  include TSort

  def initialize(param)
    @param = param
  end

  def tsort_each_node(&block)
    @param.each_value(&block)
  end

  def tsort_each_child(param, &block)
    @param.each_value.select  { |i|
      next unless i.respond_to?(:before) && i.respond_to?(:after)
      next unless param.respond_to?(:after)
      i.before == param.name || i.name == param.after
    }.each(&block)
  end
end
