# encoding: UTF-8

#
# Author:: Greg Lu (<greg.lu@gmail.com>)
# Cookbook Name:: dropwizard
# Resource:: default

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
