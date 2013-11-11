# encoding: UTF-8

# Cookbook Name:: dropwizard
# Resource:: default
# Author:: Greg Lu (<greg.lu@gmail.com>)
#
# Copyright 2013 Gregory Lu
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

actions :install, :delete, :disable
default_action :install

def initialize(*args)
  super
  @action = :install
  @run_context.include_recipe 'apt', 'java'
end

attribute :name,          kind_of: String, default: nil,
                          required: true, name_attribute: true

attribute :path,          kind_of: String, default: nil

attribute :java_bin,      kind_of: String, default: nil
attribute :jvm_options,   kind_of: String, default: ''
attribute :jar_file,      kind_of: String, default: nil
attribute :arguments,     kind_of: String, default: 'server'

attribute :pid_path,      kind_of: String, default: '/var/run'
attribute :user,          kind_of: String, default: nil
attribute :group,         kind_of: String, default: nil

attribute :init_script_source,
          kind_of: String, default: 'dropwizard-init.conf.erb'

attribute :init_script_cookbook,
          kind_of: String, default: 'dropwizard'
