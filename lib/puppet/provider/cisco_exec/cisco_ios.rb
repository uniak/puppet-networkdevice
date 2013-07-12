require 'puppet/util/network_device'

Puppet::Type.type(:cisco_exec).provide :cisco_ios, :parent => Puppet::Provider do
  mk_resource_methods

  def run(command, context)
    # TODO: Corner Cases
    dev = Puppet::Util::NetworkDevice.current
    txt = ''
    if context == :conf
      dev.switch.transport.command('conf t', :prompt => /\(config\)#\s?\z/n)
      dev.switch.transport.command(command) do |out|
        txt << out
      end
      dev.switch.transport.command('end')
    else
      dev.switch.transport.command(command) do |out|
        txt << out
      end
    end
    return txt
  end
end
