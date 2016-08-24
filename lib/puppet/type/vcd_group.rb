# Copyright (C) 2013-2016 VMware, Inc.
require 'pathname'
vmware_module = Puppet::Module.find('vmware_lib', Puppet[:environment].to_s)
require File.join vmware_module.path, 'lib/puppet/property/vmware'

Puppet::Type.newtype(:vcd_group) do
  @doc = 'Manage vCD groups.'

  ensurable do
    newvalue(:present) do
      provider.create
    end

    newvalue(:absent) do
      provider.destroy
    end

    defaultto(:present)
  end

  newparam(:name, :namevar => true) do
    desc 'group name.'
    newvalues(/\w/)
  end

  newproperty(:role_name) do
    desc 'predefined group role.'
    newvalues(/\w/)
  end

  newparam(:org_name) do
    desc 'organization assignment for group.'
    newvalues(/\w/)
  end

  autorequire(:transport) do
    self[:name]
  end
end
