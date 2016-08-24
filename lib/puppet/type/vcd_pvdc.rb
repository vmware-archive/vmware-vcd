# Copyright (C) 2013-2016 VMware, Inc.
require 'pathname'
vmware_module = Puppet::Module.find('vmware_lib', Puppet[:environment].to_s)
require File.join vmware_module.path, 'lib/puppet/property/vmware'
require 'scanf'

Puppet::Type.newtype(:vcd_pvdc) do
  @doc = "Manage vcd provider vdc's."

  ensurable do
    newvalue(:present) do
      provider.create
    end

    newvalue(:absent) do
      provider.destroy
    end

    defaultto(:present)
  end

  newparam(:pvdc_name, :namevar => true) do
    desc 'pvdc name'
    newvalues(/\w/)
  end

  newparam(:vim_server_name, :parent => Puppet::Property::VMware ) do
    desc 'vc hostname or ip address.'
    newvalues(/\w/)
  end

  newparam(:resource_pool, :parent => Puppet::Property::VMware) do
    desc 'a pvdc needs exactly 1 resource pool for its initial creation, other resource pools can be added afterwards'
  end

  newproperty(:is_enabled, :parent => Puppet::Property::VMware) do
    desc 'whether or not the provider vdc is enabled'
    newvalues(/\w/)
    munge do |value|
      value.to_s
    end
  end

  newparam(:storage_profile, :parent => Puppet::Property::VMware) do
    desc 'storage profile to be used'
    newvalues(/\w/)
  end

  newproperty(:highest_supported_hardware_version, :parent => Puppet::Property::VMware) do
    desc 'highest supported hardware version supported for vcd, ex 9'
    newvalues(/^\d+$/)
    munge do |value|
      newval = "%02.2d" % (value.to_s.scanf("%d"))
      "vmx-#{newval}"
    end
    defaultto('vmx-09')
  end

  newparam(:default_password, :parent => Puppet::Property::VMware) do
    desc 'default password for adding the esx hosts into vcd'
    newvalues(/\w/)
  end

  newparam(:default_username, :parent => Puppet::Property::VMware) do
    desc 'default username for adding the esx hosts into vcd'
    newvalues(/\w/)
  end

  newproperty(:description) do
    desc 'optional description for this pvdc'
    newvalues(/\w/)
  end

  autorequire(:transport) do
    self[:name]
  end

  autorequire(:vcd_vc) do
    self[:vim_server_name]
  end
end
