# Copyright (C) 2013-2016 VMware, Inc.
provider_path = Pathname.new(__FILE__).parent.parent
require File.join(provider_path, 'vcd')

Puppet::Type.type(:vcd_user).provide(:vcd_user, :parent => Puppet::Provider::Vcd) do
  @doc = 'Manage vCD users.'

  def exists?
    name = resource[:name]
    users = ensure_array(nested_value(org_view,%w{Users UserReference}))
    user = users.find{|x| x['@name'] == name}
    @user_ref = user['@href'] if user.is_a? Hash
  end

  def user
    @user ||= get(uri_path(@user_ref))['User']
  rescue Exception => e
    {}
  end

  def org_href(org_name=resource[:org_name])
    result = admin_element('OrganizationReferences', org_name)
    raise Puppet::Error, "Invalid org_name #{org_name}" unless result.is_a? ::Hash
    result['@href']
  end

  def org_view
    url = uri_path(org_href)
    nested_value(get(url), %w{AdminOrg})
  end

  def link(type)
    org_link = nested_value(org_view,%w{Link})
    org_link.find{|x| x['@type'] == type}
  end

  def role_href
    result = admin_element('RoleReferences', resource[:role_name])
    raise Puppet::Error, "Invalid role #{resource[:role_name]}" unless result.is_a? ::Hash
    result['@href']
  end

  def session_data
    data                       = Hash.new({})
    user                       = camel_up(:User)
    data[user]                 = {}
    user_name                  = resource[:name]
    attributes                 = {:name => user_name, :xmlns => 'http://www.vmware.com/vcloud/v1.5'}
    data[:attributes!]         = {user => attributes}
    data[user]['FullName']     = resource[:full_name]
    data[user]['EmailAddress'] = resource[:email_address]
    data[user]['IsEnabled']    = resource[:is_enabled]
    data[user]['IsExternal']   = resource[:is_external]
    data[user]['ProviderType'] = resource[:provider_type]
    data[user]['Role/']        = {}
    data[user][:attributes!]   = {'Role/' => {:href => role_href}}
    data[user]['Password']     = resource[:password]
    order = %w{FullName EmailAddress IsEnabled IsExternal ProviderType Role/ Password}
    data[user].each { |key,value| 
      if value.nil? 
        data[user].delete(key)
        order.delete(key)
      end
    }
    data[user][:order!]        = order
    data
  end

  properties = Puppet::Type.type(:vcd_user).properties.collect{|p| p.name}
  properties.each do |prop|
    define_method(prop) do
      user[camel_up(prop)]
    end
  end

  def role_name
    user['Role']['@name']
  end

  def create
    type = 'application/vnd.vmware.admin.user+xml'
    url  = uri_path(link(type)['@href'])
    post(url, session_data, type)
  end

  def destroy
    delete(uri_path(@user_ref))
  end
end
