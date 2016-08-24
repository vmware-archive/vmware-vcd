# Copyright (C) 2013-2016 VMware, Inc.
provider_path = Pathname.new(__FILE__).parent.parent
require File.join(provider_path, 'vcd')

Puppet::Type.type(:vcd_hybrid).provide(:vcd_hybrid, :parent => Puppet::Provider::Vcd) do
  @doc = 'Manage vcd hybrid settings'
  include PuppetX::VMware::Util

  def hybrid_settings
    url = prefix_uri_path('api/admin/hybrid/settings')
    @hybrid_settings ||=
      begin
        nested_value(get(url), [ 'HybridSettings' ])
      end
  end

  def camel(prop)
    camel_prop = PuppetX::VMware::Util.camelize(prop, :upper)
  end

  Puppet::Type.type(:vcd_hybrid).properties.collect{|x| x.name}.reject{|x| x == :ensure}.each do |prop|
    define_method(prop) do
      camel_prop = camel(prop)
      hybrid_settings[camel_prop]
    end

    define_method("#{prop}=".to_sym) do |value|
      camel_prop       = camel(prop)
      type             = hybrid_settings['Link']['@type']
      prop_link        = uri_path(hybrid_settings['@href'])
      data             = hybrid_settings
      data[camel_prop] = value
      # needed since vcd is expecting these in a specific order
      order = [ 'Link', 'CloudProxyBaseUri', 'CloudProxyBaseUriPublicCertChain', 'CloudProxyBaseUriOverride', 'CloudProxyFromCloudTunnelHost', 'CloudProxyFromCloudTunnelHostOverride' ]
      data[:order!] = order - (order - data.keys) 
      Puppet.debug("updating prop: #{prop}")
      put(prop_link, {'HybridSettings' => data}, type)
    end
  end
end
