# frozen_string_literal: true

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

property :path,          String
property :java_bin,      String
property :jvm_options,   String, default: ''
property :jar_file,      String
property :arguments,     String, default: 'server'

property :config_file,   String
property :safe_restart,  [true, false], default: false
property :log_directory, String

property :user,          String, required: true
property :group,         String

property :init_platform, String

default_action :install

action_class do
  def whyrun_supported?
    true
  end
end

action :install do
  app_name = new_resource.name
  app_user = new_resource.user
  app_group = new_resource.group

  declare_resource(:user, app_user) do
    system true
    home '/nonexistent'
    shell '/bin/false'
  end

  # Setting up the folder/file paths for the app.
  # Retrieves the settings from the LWRP, or defaults them to
  # a few places along with the app_name.
  app_path = new_resource.path || "/opt/#{app_name}"

  directory app_path do
    recursive true
    owner app_user
    group app_group unless app_group.nil?
    mode 0755
  end

  unless new_resource.log_directory.nil?
    directory new_resource.log_directory do
      recursive true
      owner app_user
      group app_group unless app_group.nil?
      mode 0755
    end
  end

  # Set the jar file location, if provided through LWRP, otherwise
  # default it to the app_path with a file named after the app.
  #
  # Note: A jar file isn't required to complete the Chef run, but will
  # be needed to start up the service.
  jar_file = new_resource.jar_file || ::File.join(app_path, "#{app_name}.jar")
  jar_exists = ::File.exist?(jar_file)

  unless jar_exists
    Chef::Log.warn "\n" \
      "================================================================\n" \
      "#{app_name} dropwizard service cannot start until #{jar_file} exists\n" \
      "================================================================\n"
  end

  # puts the application arguments into an array with the following order:
  # - "-jar" string
  # - jar file path
  # - all provided arguments, split by the ' ' character
  # - config file, if provided
  # optionally prefixed by jvm_options (split by the ' ' character), if provided.
  app_args = ['-jar', jar_file, *new_resource.arguments.split(' ')]

  app_args.push(new_resource.config_file) unless new_resource.config_file.nil?

  unless new_resource.jvm_options.empty?
    app_args = new_resource.jvm_options.split(' ').push(*app_args)
  end

  # pleaserun managed service created based on the app_name
  dropwizard_pleaserun app_name do
    name app_name
    program get_java_path(new_resource)
    args app_args
    user app_user
    group app_group unless app_group.nil?
    log_directory new_resource.log_directory unless new_resource.log_directory.nil?
    platform new_resource.init_platform unless new_resource.init_platform.nil?

    description "dropwizard application #{app_name}"
    action :create

    notifies :restart, "service[install_dropwizard_#{app_name}]", :delayed if jar_exists
  end

  service "install_dropwizard_#{app_name}" do
    service_name app_name
    supports restart: true, status: true

    # Only start the service if the JAR is deployed to this server
    action(jar_exists ? %i[enable start] : :nothing)
  end

  # The presence of this restart file indicates that a previous attempt
  # to restart the service failed the config check, and should be
  # re-attempted again on the next chef run.
  restart_file = "/var/run/#{app_name}.restart"
  if ::File.exist?(restart_file)
    Chef::Log.info "Restart file '#{restart_file}' exists. Attempting service restart."
    action_restart
  end
end

action :restart do
  app_name = new_resource.name
  app_user = new_resource.user
  jar_file = new_resource.jar_file || ::File.join(app_path, "#{app_name}.jar")

  if new_resource.safe_restart && !new_resource.config_file.nil?
    bash 'config_safe_restart' do
      code "touch /var/run/#{app_name}.restart && " \
           "sudo -u #{app_user} -- " \
           "#{get_java_path(new_resource)} -jar #{jar_file} check #{new_resource.config_file} && " \
           "rm -f /var/run/#{app_name}.restart"
      ignore_failure true
    end

    service "restart_dropwizard_#{app_name}" do
      service_name app_name
      not_if { ::File.exist?("/var/run/#{app_name}.restart") }
      action :restart
    end
  else
    service "restart_dropwizard_#{app_name}" do
      service_name app_name
      action :restart
    end
  end
end

action :disable do
  service "disable_dropwizard_#{new_resource.name}" do
    service_name app_name
    action %i[stop disable]
  end
end

action :delete do
  app_name = new_resource.name
  app_path = new_resource.path || "/opt/#{app_name}"
  app_user = new_resource.user

  service "delete_dropwizard_#{app_name}" do
    service_name app_name
    action %i[stop disable]
  end

  dropwizard_pleaserun app_name do
    name app_name
    program get_java_path(new_resource)
    platform new_resource.init_platform unless new_resource.init_platform.nil?
    action :remove
  end

  directory app_path do
    recursive true
    action :delete
  end

  declare_resource(:user, app_user) do
    action :remove
  end
end

##
# Gets a path to the java binary:
# 1) If "java_bin" is configured with the LWRP, then use it
# 2) Runs a "which java" in shell, and retrieve stdout
# 3) When all else fails, return "/usr/bin/java"
def get_java_path(resource)
  return resource.java_bin if !resource.java_bin.nil? && !resource.java_bin.empty?

  cmd = Mixlib::ShellOut.new('which java').tap(&:run_command)
  cmd_output = cmd.stdout.chomp
  !cmd_output.empty? ? cmd_output : '/usr/bin/java'
end
