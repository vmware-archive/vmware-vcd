# Copyright (C) 2013-2016 VMware, Inc.
require 'spec_helper'
require 'spec/fixtures/modules/vmware_lib/lib/puppet_x/puppetlabs/transport.rb'
require 'spec/fixtures/modules/vcd/lib/puppet_x/puppetlabs/transport/vcd.rb'

describe PuppetX::Puppetlabs::Transport::Vcd do

  before :all do
    @params = {
      :name      => 'vcd_transport',
      :username  => 'vcd_admin',
      :password  => 'password',
      :server    => 'vcd_fqdn',
    }
  end

  context 'initialization' do
    before :all do
      @transport = PuppetX::Puppetlabs::Transport::Vcd.new( @params )
    end

    context 'with default options' do
      it 'should complete without errors' do
        expect{ PuppetX::Puppetlabs::Transport::Vcd.new( @params ) }.to_not raise_error
      end
  
      it 'should default transport.org to "system"' do
        expect( @transport.org ).to eq('system')
      end
   
      it 'should default transport.version to "5.1"' do
        expect( @transport.version ).to eq('5.1')
      end
  
      it 'should default transport.api_prefix to an empty string' do
        expect( @transport.api_prefix ).to eq('')
      end
  
      it 'should default transport.preserve_api_prefix to false' do
        expect( @transport.preserve_api_prefix ).to eq(false)
      end
    end # End context 'initialization' do

    context 'with new options' do
      before :all do
       options = {
         'org'                 => 'test_org',
         'timeout'             => 500,
         'ver'                 => '6.0',
         'api_prefix'          => '/api/test',
         'preserve_api_prefix' => 'true'
       }
       @new_params = @params
       @new_params[:options] = options
       @custom_transport = PuppetX::Puppetlabs::Transport::Vcd.new( @new_params )
      end

      it 'should complete without errors' do
        expect{ PuppetX::Puppetlabs::Transport::Vcd.new( @new_params ) }.to_not raise_error
      end
  
      it 'should modify transport.org' do
        expect( @custom_transport.org ).to eq('test_org')
      end
   
      it 'should modify transport.version' do
        expect( @custom_transport.version ).to eq('6.0')
      end
  
      it 'should modify transport.api_prefix' do
        expect( @custom_transport.api_prefix ).to eq('/api/test/')
      end
  
      it 'should modify transport.preserve_api_prefix' do
        expect( @custom_transport.preserve_api_prefix ).to eq('true')
      end
    end # End context 'with new options' do
  end # End context 'initialization' do

  context 'attributes' do
    before :all do
      @transport = PuppetX::Puppetlabs::Transport::Vcd.new( @params )
    end

    it 'should have accessor: rest' do
      expect( @transport.methods ).to include(:rest)
      expect( @transport.methods ).to include(:rest=)
    end

    it 'should have reader: name' do
      expect( @transport.methods ).to include(:name)
    end

    it 'should have reader: user' do
      expect( @transport.methods ).to include(:user)
    end

    it 'should have reader: password' do
      expect( @transport.methods ).to include(:password)
    end

    it 'should have reader: host' do
      expect( @transport.methods ).to include(:host)
    end

    it 'should have reader: token' do
      expect( @transport.methods ).to include(:token)
    end

    it 'should have reader: org' do
      expect( @transport.methods ).to include(:org)
    end

    it 'should have reader: version' do
      expect( @transport.methods ).to include(:version)
    end

    it 'should have reader: api_prefix' do
      expect( @transport.methods ).to include(:api_prefix)
    end

    it 'should have reader: preserve_api_prefix' do
      expect( @transport.methods ).to include(:preserve_api_prefix)
    end
  end # End context 'attributes' do
end
