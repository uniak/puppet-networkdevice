Puppet::Type.newtype(:cisco_hsrp_standby_group) do
  @doc = "This represents a HSRP standby group on a specific interface."

  apply_to_device

  autorequire('cisco_interface') do
    self[:parent_interface]
  end

  def self.title_patterns
    [
      [ /^([-_\w]+)\/(\d+)$/ , [ [:parent_interface ], [:standby_group] ] ],
      [ //, [] ]
    ]
  end

  newparam(:parent_interface) do
    desc "The name of the parent interface, automatically parsed from the title."
    newvalues(/^[-_\w]+$/)
    isnamevar
  end

  newparam(:standby_group) do
    desc "The number of this HSRP standby group, automatically parsed from the title."
    newvalues(/^\d+$/)
    isnamevar
  end
  
  def name
    "#{self[:parent_interface]}/#{self[:standby_group]}"
  end

  newparam(:name) do
    desc "Synthetic parameter that is required by the puppet infrastructure to store the title."
  end

  newproperty(:ip) do
    desc "Enable HSRP IPv4 and set the virtual IP address."
    isrequired
    newvalues(/^\d+\.\d+\.\d+\.\d+$/)
  end

  newproperty(:timers) do
    desc "Hello and hold timers."
    defaultto(:absent)
    newvalue(:absent)
    newvalues(/^msec \d+ msec \d+$/)
    newvalues(/^\d+ \d+$/)
  end

  newproperty(:authentication) do
    desc "Authentication."
    defaultto(:absent)
    newvalue(:absent)
    newvalues(/.*/)
  end

  newproperty(:priority) do
    desc "Priority level."
    defaultto(:absent)
    newvalue(:absent)
    newvalues(/^\d+$/)
  end

  newproperty(:preempt) do
    desc "Overthrow lower priority Active routers."
    defaultto(:absent)
    newvalue(:absent)
    newvalue(:present)
  end

  newproperty(:preempt_delay_minimum) do
    desc "Wait before preempting at least this long (seconds)."
    defaultto(:absent)
    newvalue(:absent)
    newvalues(/^\d+$/)
  end

  newproperty(:preempt_delay_reload) do
    desc "Wait before preempting after a reload (seconds)."
    defaultto(:absent)
    newvalue(:absent)
    newvalues(/^\d+$/)
  end

  newproperty(:preempt_delay_sync) do
    desc "Wait for IP redundancy clients at least this long (seconds)."
    defaultto(:absent)
    newvalue(:absent)
    newvalues(/^\d+$/)
  end
end

