# Copyright (C) 2013-2016 VMware, Inc.
provider_path = Pathname.new(__FILE__).parent.parent
require File.join(provider_path, 'vcd')

Puppet::Type.type(:vcd_system).provide(:vcd_system, :parent => Puppet::Provider::Vcd) do
  @doc = 'Manage vcd system settings'
  include PuppetX::VMware::Util

  def general_settings
    url = prefix_uri_path('api/admin/extension/settings/general')
    @general_settings ||=
      begin
        results = nested_value(get(url), [ 'vmext:GeneralSettings' ] )
      end
  end

  def system_settings
    url = prefix_uri_path('api/admin/extension/settings')
    @system_settings ||=
      begin
        results = nested_value(get(url), [ 'vmext:SystemSettings' ] )
      end
  end

  def camel(prop)
    camel_prop = PuppetX::VMware::Util.camelize(prop, :upper)
  end

   # set the order for elements since vcd expects them this way
   # TODO, see if there is a way to get these dynamically
  def settings_order
    { :amqp_settings => [
        'vmext:AmqpHost',
        'vmext:AmqpPort',
        'vmext:AmqpUsername',
        'vmext:AmqpPassword',
        'vmext:AmqpExchange',
        'vmext:AmqpVHost',
        'vmext:AmqpUseSSL',
        'vmext:AmqpSslAcceptAll',
        'vmext:AmqpPrefix',
      ],
      :branding_settings => [
        'vmext:CompanyName',
        'vmext:LoginPageCustomizationTheme',
        'vmext:Theme',
        'vmext:PreviewCustomTheme',
        'vmext:FinalCustomTheme',
        'vmext:AboutCompanyUrl',
        'vmext:SupportUrl',
        'vmext:SignUpUrl',
        'vmext:ForgotUserNameOrPasswordURL',
      ],
      :general_settings => [
        'vmext:AbsoluteSessionTimeoutMinutes',
        'vmext:ActivityLogDisplayDays',
        'vmext:ActivityLogKeepDays',
        'vmext:AllowOverlappingExtNets',
        'vmext:ChargebackEventsKeepDays',
        'vmext:ChargebackTablesCleanupJobTimeInSeconds',
        'vmext:ConsoleProxyExternalAddress',
        'vmext:HostCheckDelayInSeconds',
        'vmext:HostCheckTimeoutSeconds',
        'vmext:InstallationId',
        'vmext:IpReservationTimeoutSeconds',
        'vmext:SyslogServerSettings',
        'vmext:LoginNameOnly',
        'vmext:PrePopDefaultName',
        'vmext:QuarantineEnabled',
        'vmext:QuarantineResponseTimeoutSeconds',
        'vmext:RestApiBaseHttpUri',
        'vmext:RestApiBaseUri',
        'vmext:RestApiBaseUriPublicCertChain',
        'vmext:SessionTimeoutMinutes',
        'vmext:ShowStackTraces',
        'vmext:SyncStartDate',
        'vmext:SyncIntervalInHours',
        'vmext:SystemExternalHttpAddress',
        'vmext:SystemExternalAddress',
        'vmext:SystemExternalAddressPublicCertChain',
        'vmext:TransferSessionTimeoutSeconds',
        'vmext:VerifyVcCertificates',
        'vmext:VcTruststorePassword',
        'vmext:VcTruststoreContents',
        'vmext:VcTruststoreType',
        'vmext:VmrcVersion',
        'vmext:VerifyVsmCertificates',
        'vmext:ElasticAllocationPool',
      ],
      :email_settings => [
        'vmext:SenderEmailAddress',
        'vmext:EmailSubjectPrefix',
        'vmext:EmailToAllAdmins',
        'vmext:AlertEmailToAllAdmins',
        'vmext:AlertEmailTo',
        'vmext:SmtpSettings',
      ],
      :ldap_settings => [
        'vmext:HostName',
        'vmext:Port',
        'vmext:IsSsl',
        'vmext:IsSslAcceptAll',
        'vmext:Realm',
        'vmext:PagedSearchDisabled',
        'vmext:PageSize',
        'vmext:MaxResults',
        'vmext:MaxUserGroups',
        'vmext:SearchBase',
        'vmext:UserName',
        'vmext:Password',
        'vmext:AuthenticationMechanism',
        'vmext:GroupSearchBase',
        'vmext:IsGroupSearchBaseEnabled',
        'vmext:ConnectorType',
        'vmext:UserAttributes',
        'vmext:GroupAttributes',
        'vmext:UseExternalKerberos',
      ],
      :ldap_user_attributes => [
        'vmext:ObjectClass',
        'vmext:ObjectIdentifier',
        'vmext:UserName',
        'vmext:Email',
        'vmext:FullName',
        'vmext:GivenName',
        'vmext:Surname',
        'vmext:Telephone',
        'vmext:GroupMembershipIdentifier',
        'vmext:GroupBackLinkIdentifier',
      ],
      :ldap_group_attributes => [
        'vmext:ObjectClass',
        'vmext:ObjectIdentifier',
        'vmext:GroupName',
        'vmext:Membership',
        'vmext:MembershipIdentifier',
        'vmext:BackLinkIdentifier',
      ],
      :password_policy => [
        'vmext:AccountLockoutEnabled',
        'vmext:AdminAccountLockoutEnabled',
        'vmext:InvalidLoginsBeforeLockout',
        'vmext:AccountLockoutIntervalMinutes',
      ],
      # not a property, but sub level of email_settings
      :smtp_settings => [
        'vmext:UseAuthentication',
        'vmext:SmtpServerName',
        'vmext:SmtpServerPort',
        'vmext:ssl',
        'vmext:Username',
        'vmext:Password',
      ],
      # not a property, but sub level of general_settings
      :syslog_order => [
        'vcloud:SyslogServerIp1',
        'vcloud:SyslogServerIp2',
      ],
    }
  end

  Puppet::Type.type(:vcd_system).properties.collect{|x| x.name}.reject{|x| x == :ensure}.each do |prop|
    define_method(prop) do
      system_settings["vmext:#{camel(prop)}"]
    end

    define_method("#{prop}=".to_sym) do |value|
      camel_prop = camel(prop)
      vmext_name = "vmext:#{camel_prop}"
      type       = system_settings[vmext_name]['@type']
      raise("type was not found for property: #{prop}") if not type
      # substitute host url in case backend host differs from customer showing url
      prop_link  = uri_path(system_settings[vmext_name]['@href'])
      raise("href was not found for property: #{prop}") if not prop_link
      data       = replace_properties(prop,value)

      # specify any required sub-level ordering
      if settings_order[prop]
        case prop.to_s
        when 'email_settings'
          data[vmext_name]['vmext:SmtpSettings'][:order!] = settings_order[:smtp_settings] & nested_value(data, [vmext_name,'vmext:SmtpSettings'],{}).keys
        when 'general_settings'
          data[vmext_name]['vmext:SyslogServerSettings'] ||= {}
          data[vmext_name]['vmext:SyslogServerSettings'][:order!] = settings_order[:syslog_order] & nested_value(data, [vmext_name, 'vmext:SyslogServerSettings'],{}).keys
        when 'ldap_settings'
          data[vmext_name]['vmext:UserAttributes'] ||= {}
          data[vmext_name]['vmext:GroupAttributes'] ||= {}
          data[vmext_name]['vmext:UserAttributes'][:order!] = settings_order[:ldap_user_attributes] & nested_value(data, [vmext_name, 'vmext:UserAttributes'],{}).keys
          data[vmext_name]['vmext:GroupAttributes'][:order!] = settings_order[:ldap_group_attributes] & nested_value(data, [vmext_name, 'vmext:GroupAttributes'],{}).keys
        else
          # do nothing by default
        end
        data[vmext_name][:order!] = settings_order[prop] & nested_value(data, [vmext_name],{}).keys
      end

      Puppet.debug("updating #{prop}, using the path: #{prop_link} and the type: #{type}")
      put(prop_link, data, type)
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

  def replace_properties(prop,value)
    vmext_name = "vmext:#{camel(prop)}"
    type       = system_settings[vmext_name]['@type']

    data = { vmext_name => rem_nil_vals(system_settings[vmext_name]).merge(value) }
    vmext_attr   = vmw_extension['@xmlns:vmext']
    vcloud_attr  = vmw_extension['@xmlns:vcloud']
    data[vmext_name]['@xmlns:vmext'] = vmext_attr
    data[vmext_name]['@xmlns:vcloud'] = vcloud_attr
    # even though api doc says this is ok, it is not
    data[vmext_name].delete('vcloud:Link')
    data
  end

  # lookup service has its own way of doing things
  def lookup_service_settings=(lookup_settings)
   vmext_name = 'vmext:LookupServiceSettings'
   unreg_msg  = "lookup service has already been registered, you must unregister before continuing"
   fail(unreg_msg) if not system_settings[vmext_name]['vmext:LookupServiceUrl'].nil?
   fail("lookup_service_username not found in parameters") if not resource[:lookup_service_username]
   fail("lookup_service_password not found in parameters") if not resource[:lookup_service_password]

   data = replace_properties('lookup_service_settings', resource[:lookup_service_settings])
   vmext_name_params       = 'vmext:LookupServiceParams'
   data[vmext_name_params] = data[vmext_name]
   data.delete(vmext_name)
   data[vmext_name_params]['@userName'] = resource[:lookup_service_username]
   data[vmext_name_params]['@password'] = resource[:lookup_service_password]

   # per internal docs, needs to be set this way versus using what is defined as the @type
   type       = 'application/*+xml'
   prop_link  = uri_path(system_settings[vmext_name]['@href'])
   Puppet.debug("updating lookup_service_settings, using the path: #{prop_link} and the type: #{type}")
   put(prop_link, data, type)

  end
end
