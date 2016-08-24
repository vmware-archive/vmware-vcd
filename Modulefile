name         'vmware-vcd'
source       'git@github.com:vmware/vmware-vcd.git'
author       'VMware'
license      'Apache 2.0'
summary      'VMware vCloud Director puppet module'
description  'VMware vCloud Director resource management.'
project_page 'https://github.com/vmware/vmware-vcd'

moduledir = File.dirname(__FILE__)
ENV['GIT_DIR'] = moduledir + '/.git'

git_version = %x{git describe --dirty --tags}.chomp.split('-')[0]
unless $?.success? and git_version =~ /^\d+\.\d+\.\d+/
  raise "Unable to determine version using git: #{$?} => #{git_version.inspect}"
end
version    git_version

