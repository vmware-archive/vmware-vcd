# Copyright (C) 2013-2016 VMware, Inc.
require 'pathname'
vmware_module = Puppet::Module.find('vmware_lib', Puppet[:environment].to_s)
require File.join vmware_module.path, 'lib/puppet/property/vmware'

Puppet::Type.newtype(:vcd_external_network) do
  @doc = 'Manage vCloud External Networks.'

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
    desc 'vcd external network name.'
    newvalues(/\w/)
  end

  newparam(:description) do
   desc 'vcd external network description.'
   newvalues(/\w/)
  end

  newparam(:configuration, :parent => Puppet::Property::VMware_Hash) do
    desc 'vcd external network configuration.'
  end

  newparam(:vim_port_group_ref, :parent => Puppet::Property::VMware_Hash) do
    desc 'vcd external network portgroup settings.'
  end

  newparam(:datacenter_name, :parent => Puppet::Property::VMware) do
    newvalues(/\w/)
  end

  newparam(:vim_server_name) do
    newvalues(/\w/) 
  end

  newparam(:network_name, :parent => Puppet::Property::VMware) do
    newvalues(/\w/) 
  end

end
