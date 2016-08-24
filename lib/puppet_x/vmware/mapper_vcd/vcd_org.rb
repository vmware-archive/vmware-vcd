# Copyright 2013, 2014 VMware, Inc.

require 'set'

module PuppetX::VMware::MapperVcd

  class VcdOrg < Map
    def initialize
      @initTree = {
        :AdminOrg => {
          Node => NodeData[
            :node_type => 'REST',
            :xml_ns    => 'http://www.vmware.com/vcloud/v1.5',
            :xml_type  => 'application/vnd.vmware.admin.organization+xml',
          ],
          :'@name' => LeafData[
            :prop_name => 'name',
          ],
          :'@xmlns' => LeafData[
          ],
          :Description => LeafData[
            :desc => "description of org",
          ],
          :FullName => LeafData[
            :desc => "Full name of the org",
          ],
          :IsEnabled => LeafData[
            :desc => "Whether or not org is enabled",
            :valid_enum => [:true, :false],
          ],
          :Settings => {
            Node => NodeData[
              :node_type => 'REST',
              :olio => {
                :ensure_is_class => ::Hash,
              },
            ],
            :OrgGeneralSettings => {
              Node => NodeData[
                :node_type => 'REST',
                :olio => {
                  :ensure_is_class => ::Hash,
                },
              ],
              :'@href' => LeafData[
                :desc => 'Do not use',
                :prop_name => PROP_NAME_IS_FULL_PATH,
              ],
              :CanPublishCatalogs => LeafData[
                :prop_name => PROP_NAME_IS_FULL_PATH,
                :valid_enum => [:true, :false],
              ],
              :CanPublishExternally => LeafData[
                :prop_name => PROP_NAME_IS_FULL_PATH,
                :valid_enum => [:true, :false],
              ],
              :CanSubscribe => LeafData[
                :prop_name => PROP_NAME_IS_FULL_PATH,
                :valid_enum => [:true, :false],
              ],
              :DeployedVMQuota => LeafData[
                :prop_name => PROP_NAME_IS_FULL_PATH,
                :olio => {
                  :ensure_is_class => ::String,
                },
              ],
              :StoredVmQuota => LeafData[
                :prop_name => PROP_NAME_IS_FULL_PATH,
                :olio => {
                  :ensure_is_class => ::String,
                },
              ],
              :UseServerBootSequence => LeafData[
                :prop_name => PROP_NAME_IS_FULL_PATH,
                :valid_enum => [:true, :false],
              ],
              :DelayAfterPowerOnSeconds => LeafData[
                :prop_name => PROP_NAME_IS_FULL_PATH,
                :olio => {
                  :ensure_is_class => ::Integer,
                },
              ],
            },
            :VAppLeaseSettings => {
              Node => NodeData[
                :node_type => 'REST',
                :olio => {
                  :ensure_is_class => ::Hash,
                },
              ],
              :'@href' => LeafData[
                :desc => 'Do not use',
                :prop_name => PROP_NAME_IS_FULL_PATH,
              ],
              :DeleteOnStorageLeaseExpiration => LeafData[
                :prop_name => PROP_NAME_IS_FULL_PATH,
                :valid_enum => [:true, :false],
              ],
              :DeploymentLeaseSeconds => LeafData[
                :prop_name => PROP_NAME_IS_FULL_PATH,
                :olio => {
                  :ensure_is_class => ::Integer,
                },
              ],
              :StorageLeaseSeconds => LeafData[
                :prop_name => PROP_NAME_IS_FULL_PATH,
                :olio => {
                  :ensure_is_class => ::Integer,
                },
              ],
            },
            :VAppTemplateLeaseSettings => {
              Node => NodeData[
                :node_type => 'REST',
                :olio => {
                  :ensure_is_class => ::Hash,
                },
              ],
              :'@href' => LeafData[
                :desc => 'Do not use',
                :prop_name => PROP_NAME_IS_FULL_PATH,
              ],
              :DeleteOnStorageLeaseExpiration => LeafData[
                :prop_name => PROP_NAME_IS_FULL_PATH,
                :valid_enum => [:true, :false],
              ],
              :StorageLeaseSeconds => LeafData[
                :prop_name => PROP_NAME_IS_FULL_PATH,
                :olio => {
                  :ensure_is_class => ::Integer,
                },
              ],
            },
            :OrgLdapSettings => {
              Node => NodeData[
                :node_type => 'REST',
                :olio => {
                  :ensure_is_class => ::Hash,
                },
              ],
              :'@href' => LeafData[
                :desc => 'Do not use',
                :prop_name => PROP_NAME_IS_FULL_PATH,
              ],
              :'@name' => LeafData[
                :desc => 'name',
                :prop_name => PROP_NAME_IS_FULL_PATH,
              ],
              :'@type' => LeafData[
                :desc => 'Do not use',
                :prop_name => PROP_NAME_IS_FULL_PATH,
              ],
              :OrgLdapMode => LeafData[
                :prop_name => PROP_NAME_IS_FULL_PATH,
                :desc => 'Do not use',
                :olio => {
                  :ensure_is_class => ::String,
                },
              ],
              :CustomUsersOu => LeafData[
                :prop_name => PROP_NAME_IS_FULL_PATH,
                :desc => 'Do not use',
                :olio => {
                  :ensure_is_class => ::String,
                },
              ],
              :CustomOrgLdapSettings => {
                Node => NodeData[
                  :node_type => 'REST',
                  :olio => {
                    :ensure_is_class => ::Hash,
                  },
                ],
                :'@href' => LeafData[
                  :desc => 'Do not use',
                  :prop_name => PROP_NAME_IS_FULL_PATH,
                ],
                :Hostname => LeafData[
                  :prop_name => PROP_NAME_IS_FULL_PATH,
                  :desc => 'Do not use',
                  :olio => {
                    :ensure_is_class => ::String,
                  },
                ],
                :Port => LeafData[
                  :prop_name => PROP_NAME_IS_FULL_PATH,
                  :olio => {
                    :ensure_is_class => ::Integer,
                  },
                ],
                :IsSsl => LeafData[
                  :prop_name => PROP_NAME_IS_FULL_PATH,
                  :valid_enum => [:true, :false],
                ],
                :IsSslAcceptAll => LeafData[
                  :prop_name => PROP_NAME_IS_FULL_PATH,
                  :valid_enum => [:true, :false],
                ],
                :Realm => LeafData[
                  :prop_name => PROP_NAME_IS_FULL_PATH,
                  :olio => {
                    :ensure_is_class => ::String,
                  },
                ],
                :SearchBase => LeafData[
                  :prop_name => PROP_NAME_IS_FULL_PATH,
                  :olio => {
                    :ensure_is_class => ::String,
                  },
                ],
                :UserName => LeafData[
                  :prop_name => PROP_NAME_IS_FULL_PATH,
                  :olio => {
                    :ensure_is_class => ::String,
                  },
                ],
                :Password => LeafData[
                  :prop_name => PROP_NAME_IS_FULL_PATH,
                  :olio => {
                    :ensure_is_class => ::String,
                  },
                ],
                :Password => LeafData[
                  :prop_name => PROP_NAME_IS_FULL_PATH,
                  :olio => {
                    :ensure_is_class => ::String,
                  },
                ],
                :AuthenticationMechanism => LeafData[
                  :prop_name => PROP_NAME_IS_FULL_PATH,
                  :olio => {
                    :ensure_is_class => ::String,
                  },
                ],
                :GroupSearchBase => LeafData[
                  :prop_name => PROP_NAME_IS_FULL_PATH,
                  :olio => {
                    :ensure_is_class => ::String,
                  },
                ],
                :IsGroupSearchBaseEnabled => LeafData[
                  :prop_name => PROP_NAME_IS_FULL_PATH,
                  :valid_enum => [:true, :false],
                ],
                :ConnectorType => LeafData[
                  :prop_name => PROP_NAME_IS_FULL_PATH,
                  :olio => {
                    :ensure_is_class => ::Integer,
                  },
                ],
                :UserAttributes => {
                  Node => NodeData[
                    :node_type => 'REST',
                    :olio => {
                      :ensure_is_class => ::Hash,
                    },
                    :misc => {
                      :del_if_empty => true,
                    },
                  ],
                  :'@href' => LeafData[
                    :desc => 'Do not use',
                    :prop_name => PROP_NAME_IS_FULL_PATH,
                  ],
                  :ObjectClass => LeafData[
                    :prop_name => PROP_NAME_IS_FULL_PATH,
                    :olio => {
                      :ensure_is_class => ::String,
                    },
                  ],
                  :ObjectIdentifier => LeafData[
                    :prop_name => PROP_NAME_IS_FULL_PATH,
                    :olio => {
                      :ensure_is_class => ::String,
                    },
                  ],
                  :UserName => LeafData[
                    :prop_name => PROP_NAME_IS_FULL_PATH,
                    :olio => {
                      :ensure_is_class => ::String,
                    },
                  ],
                  :Email => LeafData[
                    :prop_name => PROP_NAME_IS_FULL_PATH,
                    :olio => {
                      :ensure_is_class => ::String,
                    },
                  ],
                  :FullName => LeafData[
                    :prop_name => PROP_NAME_IS_FULL_PATH,
                    :olio => {
                      :ensure_is_class => ::String,
                    },
                  ],
                  :GivenName => LeafData[
                    :prop_name => PROP_NAME_IS_FULL_PATH,
                    :olio => {
                      :ensure_is_class => ::String,
                    },
                  ],
                  :Surname => LeafData[
                    :prop_name => PROP_NAME_IS_FULL_PATH,
                    :olio => {
                      :ensure_is_class => ::String,
                    },
                  ],
                  :Telephone => LeafData[
                    :prop_name => PROP_NAME_IS_FULL_PATH,
                    :olio => {
                      :ensure_is_class => ::String,
                    },
                  ],
                  :GroupMembershipIdentifier => LeafData[
                    :prop_name => PROP_NAME_IS_FULL_PATH,
                    :olio => {
                      :ensure_is_class => ::String,
                    },
                  ],
                  :GroupBackLinkIdentifier => LeafData[
                    :prop_name => PROP_NAME_IS_FULL_PATH,
                    :olio => {
                      :ensure_is_class => ::String,
                    },
                  ],
                },
                :GroupAttributes => {
                  Node => NodeData[
                    :node_type => 'REST',
                    :olio => {
                      :ensure_is_class => ::Hash,
                    },
                    :misc => {
                      :del_if_empty => true,
                    },
                  ],
                  :'@href' => LeafData[
                    :desc => 'Do not use',
                    :prop_name => PROP_NAME_IS_FULL_PATH,
                  ],
                  :ObjectClass => LeafData[
                    :prop_name => PROP_NAME_IS_FULL_PATH,
                    :olio => {
                      :ensure_is_class => ::String,
                    },
                  ],
                  :ObjectIdentifier => LeafData[
                    :prop_name => PROP_NAME_IS_FULL_PATH,
                    :olio => {
                      :ensure_is_class => ::String,
                    },
                  ],
                  :GroupName => LeafData[
                    :prop_name => PROP_NAME_IS_FULL_PATH,
                    :olio => {
                      :ensure_is_class => ::String,
                    },
                  ],
                  :Membership => LeafData[
                    :prop_name => PROP_NAME_IS_FULL_PATH,
                    :olio => {
                      :ensure_is_class => ::String,
                    },
                  ],
                  :MembershipIdentifier => LeafData[
                    :prop_name => PROP_NAME_IS_FULL_PATH,
                    :olio => {
                      :ensure_is_class => ::String,
                    },
                  ],
                  :BackLinkIdentifier => LeafData[
                    :prop_name => PROP_NAME_IS_FULL_PATH,
                    :olio => {
                      :ensure_is_class => ::String,
                    },
                  ],
                },
                :UseExternalKerberos => LeafData[
                  :prop_name => PROP_NAME_IS_FULL_PATH,
                  :valid_enum => [:true, :false],
                ],
              }, # end CustomOrgLdapSettings
            },
            :OrgEmailSettings => {
              Node => NodeData[
                :node_type => 'REST',
                :olio => {
                  :ensure_is_class => ::Hash,
                },
              ],
              :'@href' => LeafData[
                :desc => 'Do not use',
                :prop_name => PROP_NAME_IS_FULL_PATH,
              ],
              :IsDefaultSmtpServer => LeafData[
                :prop_name => PROP_NAME_IS_FULL_PATH,
                :valid_enum => [:true, :false],
              ],
              :IsDefaultOrgEmail => LeafData[
                :prop_name => PROP_NAME_IS_FULL_PATH,
                :valid_enum => [:true, :false],
              ],
              :FromEmailAddress => LeafData[
                :prop_name => PROP_NAME_IS_FULL_PATH,
                :olio => {
                  :ensure_is_class => ::String,
                },
              ],
              :DefaultSubjectPrefix => LeafData[
                :prop_name => PROP_NAME_IS_FULL_PATH,
                :olio => {
                  :ensure_is_class => ::String,
                },
              ],
              :IsAlertEmailToAllAdmins => LeafData[
                :prop_name => PROP_NAME_IS_FULL_PATH,
                :valid_enum => [:true, :false],
              ],
              :AlertEmailTo => LeafData[
                :prop_name => PROP_NAME_IS_FULL_PATH,
                :olio => {
                  :ensure_is_class => ::String,
                },
              ],
              :SmtpServerSettings => {
                Node => NodeData[
                  :node_type => 'REST',
                  :olio => {
                    :ensure_is_class => ::Hash,
                  },
                ],
                :'@href' => LeafData[
                  :desc => 'Do not use',
                  :prop_name => PROP_NAME_IS_FULL_PATH,
                ],
                :IsUseAuthentication => LeafData[
                  :prop_name => PROP_NAME_IS_FULL_PATH,
                  :valid_enum => [:true, :false],
                ],
                :Host => LeafData[
                  :prop_name => PROP_NAME_IS_FULL_PATH,
                  :olio => {
                    :ensure_is_class => ::String,
                  },
                ],
                :Port => LeafData[
                  :prop_name => PROP_NAME_IS_FULL_PATH,
                  :olio => {
                    :ensure_is_class => ::Integer,
                  },
                ],
                :Username => LeafData[
                  :prop_name => PROP_NAME_IS_FULL_PATH,
                  :olio => {
                    :ensure_is_class => ::String,
                  },
                ],
                :Password => LeafData[
                  :prop_name => PROP_NAME_IS_FULL_PATH,
                  :olio => {
                    :ensure_is_class => ::String,
                  },
                ],
              },
            }, # end OrgEmailSettings
            :OrgPasswordPolicySettings => {
              Node => NodeData[
                :node_type => 'REST',
                :olio => {
                  :ensure_is_class => ::Hash,
                },
              ],
              :'@href' => LeafData[
                :desc => 'Do not use',
                :prop_name => PROP_NAME_IS_FULL_PATH,
              ],
              :AccountLockoutEnabled => LeafData[
                :prop_name => PROP_NAME_IS_FULL_PATH,
                :valid_enum => [:true, :false],
              ],
              :InvalidLoginsBeforeLockout => LeafData[
                :prop_name => PROP_NAME_IS_FULL_PATH,
                :olio => {
                  :ensure_is_class => ::Integer,
                },
              ],
              :AccountLockoutIntervalMinutes => LeafData[
                :prop_name => PROP_NAME_IS_FULL_PATH,
                :olio => {
                  :ensure_is_class => ::Integer,
                },
              ],
            }, # end OrgPasswordPolicySettings
            :OrgOperationLimitsSettings => {
              Node => NodeData[
                :node_type => 'REST',
                :olio => {
                  :ensure_is_class => ::Hash,
                },
              ],
              :'@href' => LeafData[
                :desc => 'Do not use',
                :prop_name => PROP_NAME_IS_FULL_PATH,
              ],
              :ConsolesPerVmLimit => LeafData[
                :prop_name => PROP_NAME_IS_FULL_PATH,
                :olio => {
                  :ensure_is_class => ::Integer,
                },
              ],
              :OperationsPerUser => LeafData[
                :prop_name => PROP_NAME_IS_FULL_PATH,
                :olio => {
                  :ensure_is_class => ::Integer,
                },
              ],
              :OperationsPerOrg => LeafData[
                :prop_name => PROP_NAME_IS_FULL_PATH,
                :olio => {
                  :ensure_is_class => ::Integer,
                },
              ],
            },
            :OrgFederationSettings => {
              Node => NodeData[
                :node_type => 'REST',
                :olio => {
                  :ensure_is_class => ::Hash,
                },
              ],
              :'@href' => LeafData[
                :desc => 'Do not use',
                :prop_name => PROP_NAME_IS_FULL_PATH,
              ],
              :SAMLMetadata => LeafData[
                :prop_name => PROP_NAME_IS_FULL_PATH,
                :olio => {
                  :ensure_is_class => ::String,
                },
              ],
              :Enabled => LeafData[
                :prop_name => PROP_NAME_IS_FULL_PATH,
                :valid_enum => [:true, :false],
              ],
            },
          },
          :Users => {
            Node => NodeData[
              :node_type => 'REST',
              :olio => {
                :ensure_is_class => ::Hash,
              },
            ],
          },
          :Groups => {
            Node => NodeData[
              :node_type => 'REST',
              :olio => {
                :ensure_is_class => ::Hash,
              },
            ],
          },
          :Catalogs => {
            Node => NodeData[
              :node_type => 'REST',
              :olio => {
                :ensure_is_class => ::Hash,
              },
            ],
          },
          :Vdcs => {
            Node => NodeData[
              :node_type => 'REST',
              :olio => {
                :ensure_is_class => ::Hash,
              },
            ],
          },
          :Networks => {
            Node => NodeData[
              :node_type => 'REST',
              :olio => {
                :ensure_is_class => ::Hash,
              },
            ],
          },
        },
      }
      super
    end
  end
end

