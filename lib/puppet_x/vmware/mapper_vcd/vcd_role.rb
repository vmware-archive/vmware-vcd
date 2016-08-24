# Copyright 2013, 2014 VMware, Inc.

require 'set'

module PuppetX::VMware::MapperVcd

  class VcdRole < Map
    def initialize
      @initTree = {
        :Role => {
          Node => NodeData[
            :node_type => 'REST',
            :xml_ns    => 'http://www.vmware.com/vcloud/v1.5',
            :xml_type  => 'application/vnd.vmware.admin.role+xml',
          ],
          :'@name' => LeafData[
            :misc => [:attribute],
            :prop_name => 'name',
          ],
          :Description => LeafData[
            :desc => "description of role",
          ],
          :RightReferences => {
            Node => NodeData[
              :node_type => 'REST',
              :olio => {
                :ensure_is_class => ::Hash,
              },
            ],
            :RightReference => {
              Node => NodeData[
                :node_type => 'REST',
                :olio => {
                  :ensure_is_class => ::Array,
                },
              ],
              :'@href' => LeafData[
                :desc => 'Do not use',
                :prop_name => PROP_NAME_IS_FULL_PATH,
              ],
              :'@name' => LeafData[
                :desc => 'An array of RightReference names',
                :prop_name => 'right_reference_name',
                :olio => {
                  Puppet::Property::VMware_Array => {
                    :property_option => {
                      :inclusive => :false,
                      :preserve  => :true,
                    },
                  },
                },
              ],
              :'@type' => LeafData[
                :desc => 'Do not use',
                :prop_name => PROP_NAME_IS_FULL_PATH,
              ],
            },
          },
        },
      }
      super
    end
  end
end

