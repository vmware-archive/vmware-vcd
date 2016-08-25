

# vmware-vcd

## Overview

This module uses rest client to interact with the vCloud Director API. Also for any type / provider we are requiring a vcenter name of resource[:vim_server_name] to be used for vim connections

## Installation

$ puppet module install vmware/vcd

## Documentation

This module uses Puppet Transport resources like our other modules, such as [vmware-vcenter](https://github.com/vmware/vmware-vcenter). The trasnport resource stores the conenction information for the rest client.

    # The name of the transport is referenced by other resource:
    transport { 'vcd':
      username => 'admin',
      password => 'vmware',
      server   => 'vcd.local',
    }

All vCD resources use the transport metaparameter to specify vCD instance where the resource exists.

  vcd_user { $ldap_user_name:
    ensure        => present,
    name          => $ldap_user_name,
    is_enabled    => $ldap_is_enabled,
    is_external   => $ldap_is_external,
    provider_type => $provider_type,
    role_name     => $ldap_role_name,
    org_name      => $ldap_org_name,
    transport     => Transport["vcd"],
  }

See tests folder for additional examples.

## Contributing

The vmware-vcd project team welcomes contributions from the community. If you wish to contribute code and you have not
signed our contributor license agreement (CLA), our bot will update the issue when you open a Pull Request. For any
questions about the CLA process, please refer to our [FAQ](https://cla.vmware.com/faq). For more detailed information,
refer to [CONTRIBUTING.md](CONTRIBUTING.md).

## License
Copyright (C) 2016 VMware, Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and

