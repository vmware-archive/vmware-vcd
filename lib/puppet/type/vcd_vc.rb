# Copyright (C) 2013-2016 VMware, Inc.
require 'pathname'
vmware_module = Puppet::Module.find('vmware_lib', Puppet[:environment].to_s)
require File.join vmware_module.path, 'lib/puppet/property/vmware'

Puppet::Type.newtype(:vcd_vc) do
  @doc = 'Manage vShield global config.'

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
    desc 'vcd hostname or ip address.'
  end

  newparam(:vim_server_name) do
    desc 'vc hostname or ip address.'
    newvalues(/\w/)
  end

  newparam(:shield_manager_name) do
    desc 'vshield hostname or ip address.'
    newvalues(/\w/)
  end

  newparam(:vim_server, :parent => Puppet::Property::VMware_Hash) do
  end

  newparam(:shield_manager, :parent => Puppet::Property::VMware_Hash) do
  end

  newparam(:force_vim_server_reconnect) do
    newvalues(:true,:false)
    defaultto(:false)
  end

  newparam(:refresh_storage_profiles) do
    newvalues(:true,:false)
    defaultto(:false)
  end

  autorequire(:transport) do
    self[:name]
  end
end
