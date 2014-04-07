require 'puppet/util/network_device/cisco_ios/model'
require 'puppet/util/network_device/cisco_ios/model/generic_value'
require 'puppet/util/monkey_patches_ios'

class Puppet::Util::NetworkDevice::Cisco_ios::Model::ScopedValue < Puppet::Util::NetworkDevice::Cisco_ios::Model::GenericValue
  attr_accessor :scope, :scope_name

  def scope(*args, &block)
    return @scope if args.empty? && block.nil?
    @scope = (block.nil? ? args.first : block)
  end

  def scope_name(*args, &block)
    return @scope_name if args.empty? && block.nil?
    @scope_name = (block.nil? ? args.first : block)
  end

  # pass a block if a single scope can match multiple names
  # the block must split up the given content and matched name
  # and return a list of new content and name pairs
  def scope_match(&block)
    return @scope_match if block.nil?
    @scope_match = block
  end

  def munge_scope(content, name)
    if self.scope_match.is_a? Proc
      self.scope_match.call(content, name)
    else
      [[content, name]]
    end
  end

  def extract_scope(txt)
    raise "No scope_name configured" if @scope_name.nil?
    return if txt.nil? || txt.empty?

    munged = txt.scan(scope).collect do |content,name|
      munge_scope(content,name)
    end.reduce(:+) || []

    munged.collect do |content,name|
      content if name == @scope_name
    end.reject { |v| v.nil? }.first
  end

  def parse(txt)
    result = extract_scope(txt)

    if result.nil? || result.empty?
      Puppet.debug("Scope #{scope} not found for Param #{name}")
      return
    end
    super(result)
  end
end
