# Copyright (C) 2013-2016 VMware, Inc.
provider_path = Pathname.new(__FILE__).parent.parent
require File.join(provider_path, 'vcd')

Puppet::Type.type(:vcd_group).provide(:vcd_group, :parent => Puppet::Provider::Vcd) do
  @doc = 'Manage vCD groups.'

  def exists?
    name = resource[:name]
    groups = ensure_array(nested_value(org_view,%w{Groups GroupReference}))
    group = groups.find{|x| x['@name'] == name}
    @group_ref = group['@href'] if group.is_a? Hash
  end

  def group
    @group ||= get(uri_path(@group_ref))['Group']
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
    group                       = camel_up(:Group)
    data[group]                 = {}
    group_name                  = resource[:name]
    attributes                 = {:name => group_name, :xmlns => 'http://www.vmware.com/vcloud/v1.5'}
    data[:attributes!]         = {group => attributes}
    data[group]['Role/']        = {}
    data[group][:attributes!]   = {'Role/' => {:href => role_href}}
    data
  end

  properties = Puppet::Type.type(:vcd_group).properties.collect{|p| p.name}
  properties.each do |prop|
    define_method(prop) do
      group[camel_up(prop)]
    end
  end

  def role_name
    group['Role']['@name']
  end

  def create
    type = 'application/vnd.vmware.admin.group+xml'
    url  = URI.parse(link(type)['@href']).path
    post(url, session_data, type)
  end

  def destroy
    delete(uri_path(@group_ref))
  end
end
