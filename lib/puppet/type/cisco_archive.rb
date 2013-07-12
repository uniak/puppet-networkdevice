Puppet::Type.newtype(:cisco_archive) do
  @doc = "This represents a router or switch archive configuration. There can
  be only one instance of this and it has to be called 'running'."

  apply_to_device

  newparam(:name) do
    desc "The configuration's name. Must always be 'running'."
    newvalues(:running)
    isnamevar
  end

  newproperty(:path) do
    desc "The Path where to store Backups"
    # TODO: Proper validation of the supplied Path
    newvalues(:absent, /^\S+$/)
  end

  newproperty(:write_memory) do
    desc "Enable automatic backup generation during write memory"
    newvalues(:absent, :present)
  end

  newproperty(:time_period) do
    desc "Period of time in minutes to automatically archive the running-config"
    newvalues(:absent, /^\d+$/)

    validate do |value|
      return if value == :absent
      value = value.to_i
      self.fail "'time-period' must be between 1-525600" unless value <= 525600 && value >= 1
    end
  end
end
