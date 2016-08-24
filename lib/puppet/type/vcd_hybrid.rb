# Copyright (C) 2013-2016 VMware, Inc.
require 'pathname'
vmware_module = Puppet::Module.find('vmware_lib', Puppet[:environment].to_s)
require File.join vmware_module.path, 'lib/puppet/property/vmware'

Puppet::Type.newtype(:vcd_hybrid) do
  @doc = "Manage vcd system settings."

  newparam(:name, :namevar => true) do
    desc 'vcd instance name'
    newvalues(/\w/)
  end

  newproperty(:cloud_proxy_base_uri_override) do
    desc 'vcd hybrid settings CloudProxyBaseUriOverride , introduced in vcd 5.6.2
            example: wss://192.168.1.4/cloud/proxy'
    newvalues(/^wss:\/\/\w+/)
  end

  newproperty(:cloud_proxy_base_uri, :parent => Puppet::Property::VMware_Hash) do
    desc 'vcd hybrid settings CloudProxyBaseUri , introduced in vcd 5.6.2
            example: wss://192.168.1.4/cloud'
    newvalues(/^wss:\/\/\w+/)
  end

  newproperty(:cloud_proxy_from_cloud_tunnel_host_override) do
    desc 'vcd hybrid settings CloudProxyFromCloudTunnelHostOverride , introduced in vcd 6.0
            example: fully.qualified.com'
    newvalues(/\w+/)
  end

  autorequire(:transport) do
    self[:name]
  end
end
