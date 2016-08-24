# Copyright (C) 2013-2016 VMware, Inc.
require 'pathname'
vmware_module = Puppet::Module.find('vmware_lib', Puppet[:environment].to_s)
require File.join vmware_module.path, 'lib/puppet/property/vmware'

Puppet::Type.newtype(:vcd_system) do
  @doc = "Manage vcd system settings."

  validate do
    if self[:lookup_service_settings]
      ['username','password'].each do |param|
        msg = "lookup_service_#{param} must be specified"
        fail(msg) if not self["lookup_service_#{param}".to_sym]
      end
    end

    if self[:notifications_settings]
      msg = "proper usage is { vmext:EnableNotifications => true|false }" 
      fail(msg) if !self[:notifications_settings].has_key?('vmext:EnableNotifications') or self[:notifications_settings]['vmext:EnableNotifications'].to_s !~ /^(true|false)$/ 
    end

    if self[:email_settings]
      self[:email_settings].values do |value|
        case value
        when Hash
          # check for undocumented required ssl parameter when setting SmtpServerName
          if value['vmext:SmtpSettings'] and value['vmext:SmtpSettings']['vmext:SmtpServerName']
            msg = "vmext:ssl is a required setting with vmext:SmtpServerName"
            fail(msg) if value['vmext:SmtpSettings']['vmext:ssl'].nil?
          end
        else
          # do nothing
        end
        value
      end
    end
  end

  newparam(:name, :namevar => true) do
    desc 'vcd instance name'
    newvalues(/\w/)
  end

  newproperty(:branding_settings, :parent => Puppet::Property::VMware_Hash) do
    desc 'branding vcd settings'
  end

  newproperty(:email_settings, :parent => Puppet::Property::VMware_Hash) do
    desc 'smtp settings for vcd, this follows the api exactly, so vmext:SmtpSettings'
  end

  newproperty(:general_settings, :parent => Puppet::Property::VMware_Hash) do
    desc 'general vcd settings'
  end

  newproperty(:ldap_settings, :parent => Puppet::Property::VMware_Hash) do
    desc 'ldap vcd settings'
  end

  newproperty(:amqp_settings, :parent => Puppet::Property::VMware_Hash) do
    desc 'amqp settings, this follows api directly, for 5.1, reference: http://pubs.vmware.com/vcd-51/topic/com.vmware.vcloud.api.reference.doc_51/doc/types/SystemSettingsType.html'
    def insync?(is)
      desire = @should.first.clone
      if desire.include? 'vmext:AmqpPassword' and is.is_a? Hash
        is['vmext:AmqpPassword'] = desire['vmext:AmqpPassword']
      end
      super(is)
    end
  end

  newproperty(:notifications_settings, :parent => Puppet::Property::VMware_Hash) do
    desc 'notification settings for amqp, this is hash that matches api, valid examples are:
         vmext:EnableNotifications => true
         vmext:EnableNotifications => false'
  end

  newparam(:lookup_service_username) do
    desc 'userName attribute for lookupService'
  end

  newparam(:lookup_service_password) do
    desc 'password attribute for lookupService'
  end

  newproperty(:lookup_service_settings, :parent => Puppet::Property::VMware_Hash) do
    desc 'lookup service settings, this follows api directly, for 5.5, reference: http://pubs.vmware.com/vcd-55/topic/com.vmware.vcloud.api.reference.doc_55/doc/types/SystemSettingsType.html'
  end

  autorequire(:transport) do
    self[:name]
  end
end
