# Copyright (C) 2013-2016 VMware, Inc.
provider_path = Pathname.new(__FILE__).parent.parent
require File.join(provider_path, 'vcd')

Puppet::Type.type(:vcd_vc).provide(:vcd_vc, :parent => Puppet::Provider::Vcd) do
  @doc = 'Manages vShield global config.'

  def exists?
    name             = resource[:vim_server_name]
    results          = prop_value('vmw', 'vim_server_references')
    results.find{|x| x['@name'] == name}
  end

  def replace_properties
    data               = Hash.new({})
    reg_vim            = :'vmext:RegisterVimServerParams'
    vmext_attr         = vmw_extension['@xmlns:vmext']
    vcloud_attr        = vmw_extension['@xmlns:vcloud']
    attributes         = {:'xmlns:vmext' => vmext_attr,:'xmlns:vcloud' => vcloud_attr}
    data[:attributes!] = {reg_vim => attributes}
    data[reg_vim]      = {}

    ['vim_server','shield_manager'].each do |param|
      camel_param = PuppetX::VMware::Util.camelize(param, :upper)
      resource[param.to_sym].each do |key,value|
        camel_key = PuppetX::VMware::Util.camelize(key, :upper)
        name      = resource[:"#{param}_name"]
        data[reg_vim][:"vmext:#{camel_param}"] ||= {}
        data[reg_vim][:"vmext:#{camel_param}"][:"vmext:#{camel_key}"] = value
        data[reg_vim][:attributes!] ||= {}
        data[reg_vim][:attributes!][:"vmext:#{camel_param}"] = {:name => name}
      end
    end

    # unfortunately, order matters
    vc_vsm_order = [ :"vmext:VimServer", :"vmext:ShieldManager" ]
    data[reg_vim][:order!] = vc_vsm_order
    vim_order = [:'vmext:Username', :'vmext:Password', :'vmext:Url', :'vmext:IsEnabled']
    data[reg_vim][:"vmext:VimServer"][:order!] = vim_order
    vs_order = [:'vmext:Username', :'vmext:Password', :'vmext:Url']
    data[reg_vim][:"vmext:ShieldManager"][:order!]      = vs_order
    data
  end

  def create
    type     = 'application/vnd.vmware.admin.registerVimServerParams+xml'
    url      = prefix_uri_path('api/admin/extension/action/registervimserver')
    response = post(url, replace_properties, type)
    wait_for_task(response, ["vmext:RegisterVimServerParams","vmext:VimServer","vcloud:Tasks","vcloud:Task"])
  end

  def destroy
    Puppet.notice("This feature is not implemented")
  end

  def flush
    vim_server = exists?
    if vim_server
      Puppet.debug("vim_server = #{vim_server}")
      vim_link    = uri_path(vim_server['@href'])
      type        = vim_server['@type']

      # post links not consistent enough to iterate here
      if resource[:refresh_storage_profiles]
        Puppet.notice("refreshing vcenter storage policies")
        response = post("#{vim_link}/action/refreshStorageProfiles", {}, type)
        wait_for_task(response)
      end

      if resource[:force_vim_server_reconnect]
        Puppet.notice("forcing reconnect of vcenter")
        response = post("#{vim_link}/action/forcevimserverreconnect", {}, type)
        wait_for_task(response)
      end
    end
  end

end
