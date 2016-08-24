# Copyright (C) 2013-2016 VMware, Inc.
provider_path = Pathname.new(__FILE__).parent.parent
require File.join(provider_path, 'vcd')

Puppet::Type.type(:vcd_external_network).provide(:vcd_external_network, :parent => Puppet::Provider::Vcd) do
  @doc = 'Manages vCloud External Networks.'

  def exists?
    name = resource[:name]
    results          = prop_value('vmw', 'external_network_references')
    results.find{|x| x['@name'] == name}
  end

  def replace_properties
    data               = Hash.new({})
    ext_net            = :'vmext:VMWExternalNetwork'
    vmext_attr         = vmw_extension['@xmlns:vmext']
    vcloud_attr        = vmw_extension['@xmlns:vcloud']
    name               = resource[:name]
    content_type       = 'application/vnd.vmware.admin.vmwexternalnet+xml'
    attributes         = {:'xmlns:vmext' => vmext_attr, :'xmlns:vcloud' => vcloud_attr, :name => name, :type => content_type}
    data[:attributes!] = {ext_net => attributes}
    data[ext_net]      = {}

    vpg_ref            = :'vmext:VimPortGroupRef'
    vsv_ref            = :'vmext:VimServerRef'
    server_ref         = "https://#{resource[:vim_server_name]}" + prefix_uri_path("/api/admin/extension/vimServer/#{vim_server_id}")
    object_type        = network_list.find{|x| x['vmext:MoRef'] == portgroup_id}['vmext:VimObjectType']
    sv_ref             = {'@href' => server_ref}
    pg_ref             = {:'vmext:MoRef' => portgroup_id, :'vmext:VimObjectType' => object_type}
    data[ext_net]      = {vpg_ref => pg_ref}
    data[ext_net][vpg_ref][vsv_ref] = sv_ref

    data[ext_net][:'vcloud:Description'] = resource[:description]

    %w(configuration).each do |param|
      camel_param = PuppetX::VMware::Util.camelize(param, :upper)
      resource[param.to_sym].each do |key,value|
        camel_key = PuppetX::VMware::Util.camelize(key, :upper)
        data[ext_net][:"vcloud:#{camel_param}"] ||= {}
        data[ext_net][:"vcloud:#{camel_param}"][:"vcloud:#{camel_key}"] = value
      end
      param_order = [:'vcloud:Description', :'vcloud:Configuration', :'vmext:VimPortGroupRef']
      data[ext_net][:order!] = param_order
      config_order = [:'vcloud:IpScopes', :'vcloud:FenceMode']
      data[ext_net][:'vcloud:Configuration'][:order!] = config_order
      ipscope_order = %w{vcloud:IsInherited vcloud:Gateway vcloud:Netmask vcloud:Dns1 vcloud:Dns2 vcloud:DnsSuffix vcloud:IpRanges}
      data[ext_net][:'vcloud:Configuration'][:'vcloud:IpScopes']['vcloud:IpScope'][:order!] = ipscope_order
      range_order = %w{vcloud:StartAddress vcloud:EndAddress}
      data[ext_net][:'vcloud:Configuration'][:'vcloud:IpScopes']['vcloud:IpScope']['vcloud:IpRanges']['vcloud:IpRange'][:order!] = range_order
      pg_order = [:'vmext:VimServerRef', :'vmext:MoRef', :'vmext:VimObjectType']
      data[ext_net][:'vmext:VimPortGroupRef'][:order!] = pg_order
    end
    data
  end

  def create
    content_type = 'application/vnd.vmware.admin.vmwexternalnet+xml'
    url = prefix_uri_path('api/admin/extension/externalnets')
    post(url, replace_properties, content_type)
  end

  def destroy
    Puppet.notice('This feature is not implemented')
  end

  def network_list
    url = prefix_uri_path("api/admin/extension/vimServer/#{vim_server_id}/networks")
    @network_list ||= begin
      ensure_array(nested_value(get(url), %w{vmext:VimObjectRefList vmext:VimObjectRefs vmext:VimObjectRef}))
    end
  end

end
