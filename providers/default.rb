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
use_inline_resources

def whyrun_supported?
  true
end

def check_resource(resource)
  Chef::Application.fatal!('You must provide an app name and user') if
    resource.nil? || resource.name.nil? || resource.user.nil?
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

action :install do
  check_resource(new_resource)

  app_name = new_resource.name

  # Manages the app user
  app_user = new_resource.user

  u = user app_user

  # Setting up the folder/file paths for the app.
  # Retrieves the settings from the LWRP, or defaults them to
  # a few places along with the app_name.
  app_path = new_resource.path || "/opt/#{app_name}"

  d = directory app_path do
    recursive true
    owner app_user
    group new_resource.group unless new_resource.group.nil?
    mode 0755
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
      "#{app_name} dropwizard service cannot start until " \
        "#{jar_file} exists!\n" \
      "================================================================\n"
  end

  # put application arguments into an array in the correct order:
  # -jar, jar file, all provided arguments
  # optionally prefixed by jvm_options, if provided.
  app_args = ['-jar', jar_file, *new_resource.arguments.split(' ')]
  unless new_resource.jvm_options.empty?
    app_args = new_resource.jvm_options.split(' ').push(*app_args)
  end

  # Upstart script created based on the app_name
  pr = pleaserun app_name do
    name app_name
    program get_java_path(new_resource)
    args app_args
    user app_user
    action :create
    notifies :restart, "service[#{app_name}]" if jar_exists
  end

  # Since this is an upstart script, doing a symlink to
  # 'upstart-job' will work, and include a deprecation notice.
  if platform?('ubuntu')
    link "/etc/init.d/#{app_name}" do
      to '/lib/init/upstart-job'
      only_if 'test -f /lib/init/upstart-job && test -d /etc/init.d'
    end
  end

  s = service app_name do
    provider Chef::Provider::Service::Upstart

    supports restart: false, status: true

    # Only start the service if the JAR is deployed to this server
    action(jar_exists ? [:enable, :start] : :nothing)
  end

  resources = [u, d, pr, s]
  resources_updated = resources.inject(false) { |updated, r| updated || r.updated_by_last_action? }

  new_resource.updated_by_last_action(resources_updated)
end

action :disable do
  s = service new_resource.name do
    provider Chef::Provider::Service::Upstart
    action [:disable, :stop]
  end

  new_resource.updated_by_last_action(s.updated_by_last_action?)
end

action :delete do
  app_name = new_resource.name
  app_path = new_resource.path || "/opt/#{app_name}"

  d = directory app_path do
    action :delete
    recursive true
  end

  f = file "/etc/init/#{app_name}.conf" do
    action :delete
  end

  l = link "/etc/init.d/#{app_name}" do
    action :delete
    only_if 'test -d /etc/init.d'
  end

  s = service app_name do
    provider Chef::Provider::Service::Upstart
    action [:disable, :stop]
  end

  resources = [d, f, l, s]
  resources_updated = resources.inject(false) { |updated, r| updated || r.updated_by_last_action? }

  new_resource.updated_by_last_action(resources_updated)
end
