# Copyright (C) 2013 VMware, Inc.
begin
  require 'puppet_x/puppetlabs/transport'
rescue LoadError => e
  require 'pathname' # WORK_AROUND #14073 and #7788
  vmware_module = Puppet::Module.find('vmware_lib', Puppet[:environment].to_s)
  require File.join vmware_module.path, 'lib/puppet_x/puppetlabs/transport'
end

begin
  require 'puppet_x/puppetlabs/transport/vcd'
rescue LoadError => e
  require 'pathname' # WORK_AROUND #14073 and #7788
  module_lib = Pathname.new(__FILE__).parent.parent.parent
  require File.join module_lib, 'puppet_x/puppetlabs/transport/vcd'
end

begin
  require 'puppet_x/vmware/util'
rescue LoadError => e
  require 'pathname' # WORK_AROUND #14073 and #7788
  module_lib = Pathname.new(__FILE__).parent.parent.parent
  vmware_module = Puppet::Module.find('vmware_lib', Puppet[:environment].to_s)
  require File.join vmware_module.path, 'lib/puppet_x/vmware/util'
end

begin
  require 'puppet_x/puppetlabs/transport/vsphere'
rescue LoadError => e
  require 'pathname' # WORK_AROUND #14073 and #7788
  vcenter_module = Puppet::Module.find('vcenter', Puppet[:environment].to_s)
  require File.join vcenter_module.path, 'lib/puppet_x/puppetlabs/transport/vsphere'
end

unless Puppet.run_mode.master?
  # Using Savon's library:
  require 'nori'
  require 'gyoku'
end

# TODO: Depending on number of shared methods, we might make Puppet::Provider::Vcenter parent:
class Puppet::Provider::Vcd <  Puppet::Provider
  confine :feature => :vcd

  private

  def transport
    @transport ||= begin
      PuppetX::Puppetlabs::Transport.retrieve(:resource_ref => resource[:transport], :catalog => resource.catalog, :provider => 'vcd')
    end
  end

  def rest
    transport.rest
  end

  [:get, :delete].each do |m|
    define_method(m) do |url|
      # by default, substitute out the api_prefix, unless preserve option specified
      url = url.gsub(/^#{transport.api_prefix}/, "") unless transport.preserve_api_prefix
      begin
        result = Nori.parse( rest[url].send(
          m,
          { :Accept => "application/*+xml;version=#{@transport.version}",
            'x-vcloud-authorization' => @transport.token,
          }
        ))

      rescue RestClient::Exception => e
        raise Puppet::Error, "\n#{e.exception}:\n#{e.response}"
      end
      Puppet.debug "VCD REST API #{m} #{url} result:\n#{result.inspect}"
      result
    end
  end

  [:put, :post].each do |m|
    define_method(m) do |url, data, content_type|
      # by default, substitute out the api_prefix, unless preserve option specified
      url = url.gsub(/^#{transport.api_prefix}/, "") unless transport.preserve_api_prefix
      begin
        result = rest[url].send(
          m,
          Gyoku.xml(data),
          :Accept => "application/*+xml;version=#{@transport.version}",
          'x-vcloud-authorization' => @transport.token,
          :content_type => "#{content_type}"
        )

      rescue RestClient::Exception => e
        raise Puppet::Error, "\n#{e.exception}:\n#{e.response}\n"
      end
    end
  end

  # We need the corresponding vCenter connection once vShield is connected
  def vim
    @vsphere_transport ||= PuppetX::Puppetlabs::Transport.retrieve(:resource_hash => connection, :provider => 'vsphere')
    @vsphere_transport.vim
  end

  def connection
    server = resource[:vim_server_name]
    raise Puppet::Error, "vSphere API connection failure: vShield #{resource[:transport]} not connected to vCenter." unless server
    connection = resource.catalog.resources.find{|x| x.class == Puppet::Type::Transport && x[:server] == server}
    raise Puppet::Error, "vSphere API connection failure: vCenter #{server} transport connection not available in manifest." unless connection
    connection.to_hash
  end

  def nested_value(hash, keys, default=nil)
    value = hash.dup
    keys.each_with_index do |item, index|
      unless (value.is_a? Hash) && (value.include? item)
        default = yield hash, keys, index if block_given?
        return default
      end
      value = value[item]
    end
    value
  end

  def ensure_array(value)
    # Ensure results an array. If there's a single value the result is a hash, while multiple results in an array.
    case value
    when nil
      []
    when Array
      value
    when Hash
      [value]
    else
      raise Puppet::Error, "Unknown type for munging #{value.class}: '#{value}'"
    end
  end

  def camel_up(prop)
    PuppetX::VMware::Util.camelize(prop, :upper)
  end

  def camel_lo(prop)
    PuppetX::VMware::Util.camelize(prop, :lower)
  end

  def vcd_object(url, prop)
    @object ||= begin
      nested_value(get(url), [prop])
    end
  end

  def admin_view
    @admin_view ||= vcd_object(prefix_uri_path('api/admin'), 'VCloud')
  end

  def admin_element(object, name)
    result = ensure_array(nested_value(admin_view,[object, object.chop]))
    result.find{|x| x['@name'] == name}
  end

  def prop_value(type_prefix, prop)
    type            = "application/vnd.vmware.admin.#{type_prefix}#{camel_up(prop)}+xml"
    nest_tree_array = [ "vmext:VMW#{camel_up(prop)}", "vmext:#{camel_up(prop).chop}" ]
    ensure_array(nested_value(get(type_link(type)), nest_tree_array ) )
  end

  def type_link(type)
    vcloud_link = nested_value(vmw_extension,%w{vcloud:Link})
    prop_link   = vcloud_link.find{|x| x['@type'] == type }
    raise Puppet::Error, "type: #{type} not found" if not prop_link
    # future split and send host info to rest/transport in case host differs from transport
    uri_path prop_link['@href']
  end

  def find_link(view, type, rel='add')
    if link = view['Link'].find{|link| link['@type'] =~ Regexp.new(Regexp.quote(type)) and link['@rel'] == rel}
      uri_path(link['@href'])
    else
      raise Puppet::Error, "Unable to find link #{type} in #{view}"
    end
  end

  def datacenter(name=resource[:datacenter_name])
    vim.serviceInstance.find_datacenter(name) or raise Puppet::Error, "datacenter '#{name}' not found."
  end

  def datacenter_moref(name=resource[:datacenter_name])
    datacenter._ref
  end

  def dvswitch(name=resource[:network_name])
    @dvswitch ||= begin
      dvswitches = datacenter.networkFolder.children.select {|n|
        n.class == RbVmomi::VIM::VmwareDistributedVirtualSwitch
      }
      dvswitches.find{|d| d.name == name}
    end
  end

  def dvswitch_id
    dvswitch._ref
  end

  def dvswitch_type
    dvswitch.class
  end

  def portgroup(name=resource[:network_name])
    @portgroup ||= begin
      portgroups = datacenter.network
      portgroups.find{|d| d.name == name}
    end
  end

  def portgroup_id
    portgroup._ref
  end

  def portgroup_type
    portgroup.class
  end

  def vmw_extension
    url = prefix_uri_path('api/admin/extension')
    @vmw_extension ||= begin
      results = nested_value(get(url), %w{vmext:VMWExtension} )
    end
  end

  def vim_server
    name = resource[:vim_server_name]
    @vim_server ||= begin
      results = prop_value('vmw','vim_server_references')
      results.find{|x| x['@name'] == name}
    end
  end

  def vim_server_id
    @vim_server_id ||= begin
      result = vim_server['@href']
      result.rpartition('/')[2]
    end
  end

  def uri_path(url)
    URI.parse(url).path
  end

  # for all static urls, prepend api_prefix ( default is '' )
  def prefix_uri_path(url)
    transport.api_prefix + uri_path(url)
  end

  def wait_for_task(response,nested_val = ['Task'], max_attempts = 40, retry_interval = 15)
    task = nested_value(Nori.parse(response), nested_val)
    raise Puppet::Error, "no href found for task: #{task}" unless task.has_key?('@href')
    task_result = task_check(task['@href'],max_attempts,retry_interval)
    # ensure the task completes with a success status
    raise Puppet::Error, "Error, task_result returned with status: #{task_result}" if task_result != 'success'
    task_result
  end

  def task_check(task_url,max_attempts,retry_interval)
    task_url    = uri_path(task_url)
    task_status = 'unknown'
    while max_attempts > 0
      Puppet.debug("checking task_url: #{task_url} for status")
      task        = nested_value(get(task_url), ['Task'])
      task_status = task['@status']
      operation   = task['@operation']
      Puppet.debug("current task status is: #{task_status}")
      if task_status == 'error'
        error_msg   = task['Error']['@message']
        raise Puppet::Error, "The operation: #{operation}, error'd out with message: #{error_msg}"
      end
      # only loop if the task is still running, queued, or preRunning 
      # http://pubs.vmware.com/vcd-55/topic/com.vmware.vcloud.api.reference.doc_55/doc/types/TaskType.html
      break unless task_status =~ /^(running|queued|preRunning)$/ 
      max_attempts -= 1
      sleep retry_interval
    end
    task_status
  end

  def ensure_array(value)
    # Ensure results an array. If there's a single value the result is a hash, while multiple results in an array.
    case value
    when nil
      []
    when String
      [value]
    when Array
      value
    when Hash
      [value]
    when Nori::StringWithAttributes
      [value]
    else
      raise Puppet::Error, "Unknown type for munging #{value.class}: '#{value}'"
    end
  end
end
