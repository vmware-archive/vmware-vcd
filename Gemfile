source "https://rubygems.org"

group :development, :test do
  gem 'rake'
  gem 'rspec'
  gem 'rspec-puppet'
  gem 'puppetlabs_spec_helper'
  gem 'puppet-lint'
end

puppetversion = ENV.key?('PUPPET_VERSION') ? ENV['PUPPET_VERSION'] : ['>= 3.3']
gem 'puppet', puppetversion
gem 'facter', '>= 1.7.0'

# JSON must be 1.x on Ruby 1.9
if RUBY_VERSION < '2.0'
  gem 'json', '~> 1.8'
  gem 'json_pure', '~> 1.0'
end
