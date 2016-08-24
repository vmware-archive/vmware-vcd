# Copyright (C) 2013 VMware, Inc.
gem 'rest-client', '=1.6.7' # pending changes for self-signed certs in v 1.7.2 ?
require 'rest_client' if Puppet.features.restclient? and ! Puppet.run_mode.master?

module PuppetX::Puppetlabs::Transport
  class Vcd
    attr_accessor :rest
    attr_reader :name, :user, :password, :host, :token, :org, :version, :api_prefix, :preserve_api_prefix

    def initialize(option)
      option[:options] = option[:options] || {}
      @name       = option[:name]
      @user       = option[:username]
      @password   = option[:password]
      @host       = option[:server]
      @org        = option[:options]['org'] || 'system'
      @timeout    = option[:options]['timeout'] || 300
      @version    = option[:options]['ver'] || '5.1'
      @api_prefix = option[:options]['api_prefix'] || ''
      # automatically add a beginning and trailing '/' if not included
      if @api_prefix.length > 0
        slash       = '/'
        @api_prefix = slash + @api_prefix unless @api_prefix.start_with? slash
        @api_prefix = @api_prefix + slash unless @api_prefix.end_with?   slash
      end
      @preserve_api_prefix = option[:options]['preserve_api_prefix'] || false
      Puppet.debug("#{self.class} initializing connection to: #{@host}, version: #{@version}")
    end

    def connect
      @rest ||= RestClient::Resource.new(
        "https://#{@host}",
        :user => "#{@user}@#{@org}",
        :password => @password,
        :verify_ssl => OpenSSL::SSL::VERIFY_NONE,
        :ssl_version => 'SSLv23',
        :headers => {
            :accept => "application/*+xml;version=#{@version}"
        },
        :timeout => @timeout.to_i
      )
      url = 'api/login'
      url = @api_prefix + url if @preserve_api_prefix

      response = @rest[url].post(
      nil)
      @token = response.headers[:x_vcloud_authorization]
    end

  end
end
