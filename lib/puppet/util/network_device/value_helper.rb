module Puppet::Util::NetworkDevice::ValueHelper
  def define_value_method(methods)
    methods.each do |meth|
      define_method(meth) do |*args, &block|
        # return the current value if we are called like an accessor
        return instance_variable_get("@#{meth}".to_sym) if args.empty? && block.nil?
        # set the new value if there is any
        instance_variable_set("@#{meth}".to_sym, (block.nil? ? args.first : block))
      end
    end
  end
end
