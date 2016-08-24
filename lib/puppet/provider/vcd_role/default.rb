# Copyright (C) 2013-2016 VMware, Inc.
require 'pathname'
vmware_module = Puppet::Module.find('vmware_lib', Puppet[:environment].to_s)
require File.join vmware_module.path, 'lib/puppet_x/vmware/util'
require File.join vmware_module.path, 'lib/puppet/property/vmware'
module_lib    = Pathname.new(__FILE__).parent.parent.parent.parent
require File.join module_lib, 'puppet_x/vmware/mapper_vcd'
require File.join module_lib, 'puppet/provider/vcd'

Puppet::Type.type(:vcd_role).provide(:vcd_role, :parent => Puppet::Provider::Vcd) do
  @doc = 'Manage vCD roles.'

  def nested_value *args
    PuppetX::VMware::Util::nested_value *args
  end
  def nested_value_set *args
    PuppetX::VMware::Util::nested_value_set *args
  end

  map ||= PuppetX::VMware::MapperVcd.new_map('VcdRole')

  define_method(:map) do 
    @map ||= map
  end

  def exists?
    # call exists? multiple times, settings won't change
    v ||= config_is_now and true
  end

  def create
    @flush_required = true
    @create_message ||= []
    # fetch properties from resource using provider setters
    map.leaf_list.each do |leaf|
      p = leaf.prop_name
      unless (value = @resource[p]).nil?
        self.send("#{p}=".to_sym, value)
        @create_message << "#{leaf.full_name} => #{value.inspect}"
      end
    end
  end

  def create_message
    @create_message ||= []
    "created using {#{@create_message.join ", "}}"
  end

  def destroy
    delete(uri_path config_is_now['Role']['@href']) if exists?
  end

  map.leaf_list.each do |leaf|
    define_method(leaf.prop_name) do
      value = PuppetX::VMware::MapperVcd::munge_to_tfsyms.call(
        PuppetX::VMware::Util::nested_value(config_is_now, leaf.path_is_now)
      )
    end

    define_method("#{leaf.prop_name}=".to_sym) do |value|
      nested_value_set config_should, leaf.path_should, value, transform_keys=false
      @flush_required = true
    end
  end

  def right_reference_name
    rights = nested_value(config_is_now, ['Role', 'RightReferences', 'RightReference'])
    rights = rights.map{|x|x['@name']} unless rights.nil?
    rights
  end
  alias right_names right_reference_name

  def right_reference_name=(names)
    @flush_required = true
    names   = names.uniq.sort
    # get RightReference objects known to vcd (including its extensions)
    # and find the objects that have the names requested by puppet
    rr_key1 = 'RightReferences'
    rr_key2 = 'RightReference'
    rr_list = nested_value(admin_view,[rr_key1, rr_key2])
    found   = rr_list.select{|o| names.include? o['@name']}.uniq || []
    unless names.size == found.size
      # some requested names were not found
      valid   = rr_list.map{|o| o['@name']}.sort
      invalid = names.reject{|v| valid.include? v}.sort
      fail "Failed to find #{rr_key2}: not found: #{invalid}; valid values: #{valid}"
    end
    config_should['Role']                   ||= {}
    config_should['Role'][rr_key1]          ||= {}
    config_should['Role'][rr_key1][rr_key2] ||= {}
    config_should['Role'][rr_key1][rr_key2]   = found
  end
  alias right_names= right_reference_name=

  def flush
    if @flush_required 
      config = map.prep_for_serialization config_should

      type = config['Role']['@type']
      if exists?
        url  = uri_path config['Role']['@href']
        put  url, config, type
      else
        link = nested_value(admin_view,%w{Link}).find{|x| x['@type'] == type}
        url  = uri_path link['@href']
        post url, config, type
      end
    end
  end

  def config_should
    @config_should ||= config_is_now || {}
  end

  def config_is_now
    @config_is_now ||= 
      begin
        # search the appropriate list for a reference to this resource's config
        config_ref = admin_element('RoleReferences', resource[:name]) #TODO admin_element differ for different type
        return nil unless config_ref
        # use the reference to get the config, then prepare it for use
        config = map.prep_is_now get(uri_path config_ref['@href'])
        config
      end
  end

end
