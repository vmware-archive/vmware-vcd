# Copyright (C) 2013-2016 VMware, Inc.
require 'pathname'
vmware_module = Puppet::Module.find('vmware_lib', Puppet[:environment].to_s)
require File.join vmware_module.path, 'lib/puppet/property/vmware'

Puppet::Type.newtype(:vcd_user) do
  @doc = 'Manage vCD users.'

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
    desc 'username/login.'
    newvalues(/\w/)
  end

  newproperty(:full_name) do
    desc 'user first and last name.'
    newvalues(/\w/)
  end

  newproperty(:email_address) do
    desc 'user email address.'
    newvalues(/\w/)
  end

  newproperty(:is_enabled) do
    desc 'enable user.'
    newvalues(/\w/)
  end

  newproperty(:is_external) do
    desc 'ldap user.'
    newvalues(/\w/)
  end

  newproperty(:provider_type) do
    desc 'sets user provider for SAML authentication'
  end

  newproperty(:is_locked) do
    desc 'account lock.'
    newvalues(/\w/)
  end

  newproperty(:role_name) do
    desc 'predefined user role.'
    newvalues(/\w/)
  end

  newparam(:password) do
    desc 'user password (only applied for user creation).'
    newvalues(/\w/)
  end

  newparam(:org_name) do
    desc 'organization assignment for user.'
    newvalues(/\w/)
  end

  autorequire(:transport) do
    self[:name]
  end
end
