require 'puppet/util/network_device'
require 'puppet/util/network_device/sorter'

module Puppet::Util::NetworkDevice::Dsl

  def register_param(params, klass = nil, &block)
    # Make it so that we can register multiple Params at the same time
    # and assign every Param an index number that must match the Regex
    klass ||= param_class
    @params ||= {}
    [params].flatten.each_with_index do |param, idx|
      @params[param] = klass.new(param, transport, facts, idx, &block)
    end
  end

  def register_scoped(params, scope_match, klass = nil, &block)
    int_name = name
    register_param(params, klass) do
      raise "no name set" if name.nil?
      scope scope_match
      scope_name int_name
      # Pass the Block to a Helper Method so we are in the right Scope
      # when evaluating the block
      evaluate &block
    end
  end

  def params_to_hash
    @params.inject({}) {|res, data|
      unless respond_to?(:skip_params_to_hash) && skip_params_to_hash.include?(data[0])
        unless data[1].value.nil? || data[1].value.to_s.empty?
          if data[1].value.is_a?(Hash)
            res.merge!(data[1].value)
          else
            res[data[0]] = data[1].value
          end
        end
      end
      res
    }
  end

  def register_module_after(param, mod, path_addition = "", &block)
    # Register a new Module after the required Fact has been evaluated
    # Pass a Block that must evaluate to true or false to make sure we dont
    # include Modules by accident
    @after_hooks ||= {}
    @after_hooks[param] ||= []
    @after_hooks[param] << {:mod => mod, :path_addition => path_addition, :block => block}
  end

  def register_new_module(mod, path_addition = "")
    @included_modules ||= []
    unless @included_modules.include?(mod)
      Puppet::Util::Autoload.new(self, File.join(mod_path_base, path_addition), :wrap => false).load(mod)
      if path_addition.empty?
        mod_const_base.const_get(mod.to_s.capitalize).register(self)
        @included_modules << mod
      else
        mod_const_base.const_get(path_addition.to_s.capitalize).const_get(mod.to_s.capitalize).register(self)
        @included_modules << mod
      end
    end
  end

  def evaluate_new_params
    Puppet::Util::NetworkDevice::Sorter.new(@params).tsort.each do |param|
      #Skip if the param has already been evaluated
      next if param.evaluated
      if param.cmd != false
        # Let the Transport Cache the Command for us since we are only dealing here with 'show' type commands
        out = @transport.command(param.cmd, :cache => true, :noop => false)
        # This is here for the Specs
        # FIXME
        if out.nil?
          param.evaluated = true
          next
        end
        param.parse(out)
      elsif param.match_param.is_a? Array
        param.parse([param.match_param].flatten.collect{|p|@params[p].value})
      else
        param.parse(@params[param.match_param].value)
      end
      @after_hooks ||= {}
      if @after_hooks[param.name]
        @after_hooks[param.name].each do |mod|
          register_new_module(mod[:mod], mod[:path_addition]) if mod[:block].call
        end
      end
    end
    evaluate_new_params unless @params.each_value.select {|param| param.evaluated == false}.empty?
  end

  def retrieve
    register_new_module(:base)
    evaluate_new_params
    params_to_hash
  end
end
