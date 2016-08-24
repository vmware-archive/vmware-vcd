# Copyright (C) 2013-2016 VMware, Inc.
provider_path = Pathname.new(__FILE__).parent.parent
require File.join(provider_path, 'vcd')

Puppet::Type.type(:vcd_pvdc).provide(:vcd_pvdc, :parent => Puppet::Provider::Vcd) do
  @doc = 'Manage vcd provider vdc.'

  def exists?
    name = resource[:pvdc_name]
    result = ensure_array(admin_element('ProviderVdcReferences', name))
    result.find{|x| x['@name'] == name}
  end

  def vcloud_link(type)
    result = nested_value(vmw_extension,%w{vcloud:Link})
    result.find{|x| x['@type'] == type}
  end

  def pvdc_settings
    @pvdc_settings ||= 
      begin
        name = resource[:pvdc_name]
        refs = prop_value('vmw','provider_vdc_references')
        pvdc_ref = refs.find{|x| x['@name'] == name}
        pvdc_url = uri_path(pvdc_ref['@href'])
        get(pvdc_url)
      end
  end

  def vim_server_link
    name          = resource[:vim_server_name]
    results       = prop_value('vmw','vim_server_references')
    vim_server    = results.find{|x| x['@name'] == name}
    raise Puppet::Error, "vim_server_name: #{name} not found" if not vim_server
    uri_path(vim_server['@href'])
  end

  def res_pool_obj
    res_pool_name = resource[:resource_pool]
    res_pool_link =  "#{vim_server_link}/resourcePoolList"
    resources     = ensure_array(nested_value(get(res_pool_link), [ 'vmext:ResourcePoolList', 'vmext:ResourcePool' ] ))
    res_pool      = resources.find{|x| x['@name'] == res_pool_name }
    raise Puppet::Error, "resource_pool: #{res_pool_name} was not found or is already used by another pvdc" if not res_pool
    res_pool
  end
    
  def replace_properties(name,kind)
    data               = Hash.new({})
    action             = :"vmext:VMW#{kind}"
    vim_server_name    = resource[:vim_server_name]
    vmext_attr         = vmw_extension['@xmlns:vmext']
    vcloud_attr        = vmw_extension['@xmlns:vcloud']
    attributes         = {:'xmlns:vmext' => vmext_attr,:'xmlns:vcloud' => vcloud_attr, :name => name}
    data[action]       = {}
    data[:attributes!] = { action => attributes }

    res_pool_moref     = res_pool_obj['vmext:MoRef']
    res_pool_obj_type  = res_pool_obj['vmext:VimObjectType']

    data[action][:'vmext:ResourcePoolRefs'] = {
      :'vmext:VimObjectRef' => {
        :'vmext:VimServerRef'  => '',
        :'vmext:MoRef'         => res_pool_moref,
        :'vmext:VimObjectType' => res_pool_obj_type,
        :attributes!           => { :'vmext:VimServerRef'  => {:href => "https://#{vim_server_name}/#{vim_server_link}" } },
        :order! => [:'vmext:VimServerRef', :'vmext:MoRef', :'vmext:VimObjectType'],
      }
    }
    Puppet::Type.type(:vcd_pvdc).parameters.collect.reject{|x| x.to_s =~ /^(provider|pvdc_name|vim_server_name|resource_pool)$/}.each do |param|
      if resource[param]
        camel_param = camel_up(param)
        data[action][:"vmext:#{camel_param}"] = resource[param]
      end
    end

    Puppet::Type.type(:vcd_pvdc).properties.collect{|x| x.name}.reject{|x| x.to_s =~ /^(ensure)$/}.each do |prop|
      if resource[prop]
        camel_prop = camel_up(prop)
        data[action][:"vmext:#{camel_prop}"] = resource[prop]
      end
    end

    data[action][:'vmext:VimServer'] = ''
    data[action][:attributes!] = { :'vmext:VimServer' => { :href => "https://#{vim_server_name}/#{vim_server_link}" } }
    order = [ :'vmext:ResourcePoolRefs', :'vmext:VimServer', :'vmext:HighestSupportedHardwareVersion', :'vmext:IsEnabled', :'vmext:StorageProfile', :'vmext:DefaultPassword', :'vmext:DefaultUsername' ]
    data[action][:order!] = order - (order - data[action].keys)
    data
  end

  def create
    name = resource[:pvdc_name]
    type = 'application/vnd.vmware.admin.createProviderVdcParams+xml'
    url = uri_path(vcloud_link(type)['@href'])
    response = post(url, replace_properties(name, 'ProviderVdcParams'), type)
    wait_for_task(response,['vmext:VMWProviderVdc','vcloud:Tasks','vcloud:Task'])
  end

  def destroy
    Puppet.notice("Feature not implemented")
  end

  Puppet::Type.type(:vcd_pvdc).properties.collect{|x| x.name}.reject{|x| x == :ensure}.each do |prop|
    prop_map = { :description => 'vcloud',
                 :is_enabled => 'vcloud',
                 :highest_supported_hardware_version => 'vmext',
               }
    define_method(prop) do
      ext_type = prop_map[prop]
      pvdc_settings["vmext:VMWProviderVdc"]["#{ext_type}:#{camel_up(prop)}"].to_s
    end

    define_method("#{prop}=".to_sym) do |value|
      ext_type = prop_map[prop]
      pvdc_settings["vmext:VMWProviderVdc"]["#{ext_type}:#{camel_up(prop)}"] = value
      @flush_required = true
    end
  end

  def rem_nil_vals(data)
    # TODO, make rem_nil_vals deal with array of hashes
    data.each do |k, v|
      case v
      when NilClass
        data.delete(k)
      when Array
        # do nothing, not gonna handle array of hashes for now, but maybe in future
      when Hash
        rem_nil_vals(v)
      else
        # do nothing
      end
    end
    data
  end

  def flush
    vmext_name = "vmext:VMWProviderVdc"
    if @flush_required && exists?
      url = uri_path(pvdc_settings[vmext_name]["@href"])
      type = pvdc_settings[vmext_name]["@type"]
      data = { vmext_name => rem_nil_vals(pvdc_settings[vmext_name]) }
      data[vmext_name].delete('vcloud:Link')
      put url, data, type
    end
  end

end
