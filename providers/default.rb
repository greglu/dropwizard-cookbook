#
# Author:: Greg Lu (<greg.lu@gmail.com>)
# Cookbook Name:: dropwizard
# Resource:: default

def whyrun_supported?
  true
end

def check_resource(resource)
  if resource.nil? || resource.name.nil? || resource.user.nil?
    Chef::Application.fatal!('You must provide an app name and user')
  end
end

##
# Gets a path to the java binary:
# 1) If "java_bin" is configured with the LWRP, then use it
# 2) Runs a "which java" in shell, and retrieve stdout
# 3) When all else fails, return "/usr/bin/java"
def get_java_path(resource)
  if !resource.java_bin.nil? && !resource.java_bin.empty?
    return resource.java_bin
  else
    cmd = Mixlib::ShellOut.new("which java")
    cmd.run_command
    cmd_output = cmd.stdout.chomp

    if !cmd_output.empty?
      return cmd_output
    else
      return "/usr/bin/java"
    end
  end
end


action :install do

  check_resource(new_resource)

  app_name = new_resource.name

  # Manages the app user
  app_user = new_resource.user
  user app_user

  # Setting up the folder/file paths for the app and pid file.
  # Retrieves the settings from the LWRP, or defaults them to
  # a few places along with the app_name.
  app_path = new_resource.path || "/opt/#{app_name}"
  pid_file = ::File.join(new_resource.pid_path, "#{app_name}.pid")

  directory app_path do
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
  jar_exists = ::File.exists?(jar_file)

  unless jar_exists
    Chef::Log.warn "\n" +
      "=====================================================================\n" +
      "#{app_name} dropwizard service cannot start until #{jar_file} is deployed!\n" +
      "=====================================================================\n"
  end

  # Upstart script created based on the app_name
  template "/etc/init/#{app_name}.conf" do
    source new_resource.init_script_source
    cookbook new_resource.init_script_cookbook

    mode 0644
    owner "root"
    group "root"
    variables(
      :app_name => app_name,
      :java_bin => get_java_path(new_resource),
      :app_path => app_path,
      :app_user => app_user,
      :pid_file => pid_file,
      :jar_file => jar_file,
      :jvm_options => new_resource.jvm_options,
      :arguments => new_resource.arguments
    )
    notifies :restart, "service[#{app_name}]" if jar_exists
  end

  # Since this is an upstart script, doing a symlink to
  # 'upstart-job' will work, and include a deprecation notice.
  link "/etc/init.d/#{app_name}" do
    to "/lib/init/upstart-job"
  end

  service app_name do
    provider Chef::Provider::Service::Upstart

    supports :restart => false, :status => true

    # Only start the service if the JAR is deployed to this server
    action (jar_exists ? [:enable, :start] : :nothing)
  end

end
