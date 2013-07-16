require 'puppet/util/monkey_patches_ios'

Puppet::Type.newtype(:cisco_acl) do
  @doc = "This represents an ACL."

  apply_to_device

  ensurable

  newparam(:name) do
    desc "The ACL's name."
    isnamevar
    newvalues(/^[-_\w]+$/)
  end

  newproperty(:type) do
    desc "The ACL type"
    isrequired
    newvalues(:standard)
    defaultto(:standard)
  end

  newproperty(:acl, :array_matching => :all) do
    desc "An array of strings describing the ACL according to the cisco syntax"
    newvalues(/^(permit|deny)\s+/)
    defaultto []
  end
end
