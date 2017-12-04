# frozen_string_literal: true

##
# dropwizard_pleaserun
#
# Custom resource for generating init scripts using the "pleaserun" gem.
#
# The chef-pleaserun community cookbook's customer resource had a bug where
# the platform or log directory couldn't be defined. This custom resource
# uses the same properties from that LWRP (allowing for compatibility),
# fixes the bugs, and uses the new chef 12.5+ custom resource syntax.
#

# Copied these resource properties from the chef-pleaserun cookbook
property :app_name,       String, name_attribute: true
property :user,           String
property :group,          String
property :description,    String
property :umask,          String
property :runas,          String
property :chroot,         String
property :chdir,          String
property :nice,           String
property :prestart,       String
property :program,        String, required: true
property :args,           Array,  default: []
property :platform,       String
property :target_version, String

# not part of the chef-pleaserun LWRP
property :platform_version, String
property :log_directory,    String

property :systemd_reload_enabled, [true, false], default: false
property :systemd_reload_command, String, default: '/bin/kill -HUP $MAINPID'

default_action :create

action :create do
  pr = pleaserun_setup

  pr.files.each do |path, content, perms|
    Chef::Log.debug "[dropwizard_pleaserun] #{path} - #{perms}:\n#{content}"
    file path do
      owner 'root'
      group 'root'
      mode perms || 0644
      content content
      action :create
    end
  end

  if systemd_reload_enabled? pr
    Chef::Log.info "[dropwizard_pleaserun] systemd reload command setting up for #{app_name}"

    dropin_dir = ::File.join(pr.unit_path, "#{app_name}.service.d")

    directory dropin_dir do
      recursive true
      mode 0755
    end

    template ::File.join(dropin_dir, 'reload.conf') do
      source 'systemd-reload.conf.erb'
      cookbook 'dropwizard'
      mode 0644
      variables(reload_command: systemd_reload_command)
    end
  end
end

action :remove do
  pr = pleaserun_setup

  if systemd_reload_enabled? pr
    Chef::Log.info "[dropwizard_pleaserun] systemd reload command being removed for #{app_name}"

    dropin_dir = ::File.join(pr.unit_path, "#{app_name}.service.d")

    template ::File.join(dropin_dir, 'reload.conf') do
      action :delete
    end

    directory dropin_dir do
      action :delete
    end
  end

  pr.files.each do |path, _, _|
    Chef::Log.info "[dropwizard_pleaserun] removing #{path}"
    file path do
      action :delete
    end
  end
end

# rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
def pleaserun_setup
  chef_gem 'pleaserun' do
    compile_time true
    version '>= 0.0.30'
  end

  require 'pleaserun/namespace'
  require 'pleaserun/platform/base'

  target_platform = platform
  target_platform_version = platform_version || target_version

  if target_platform.nil? || target_platform.empty?
    require 'pleaserun/detector'
    if target_platform_version.nil?
      target_platform, target_platform_version = PleaseRun::Detector.detect
    else
      target_platform = PleaseRun::Detector.detect
    end
    Chef::Log.info "[dropwizard_pleaserun] autodetected #{target_platform} " \
                   "/ #{target_platform_version}"
  end

  Chef::Log.info "[dropwizard_pleaserun] platform: #{target_platform} / " \
                 "version: #{target_platform_version}"

  require "pleaserun/platform/#{target_platform}"
  platform_klass = load_platform(target_platform)

  pr = platform_klass.new(target_platform_version.to_s)
  pr.name = app_name
  pr.user = user unless user.nil?
  pr.group = group unless group.nil?
  pr.description = description unless description.nil?
  pr.umask = umask unless umask.nil?
  pr.runas = runas unless runas.nil?
  pr.chroot = chroot unless chroot.nil?
  pr.chdir = chdir unless chdir.nil?
  pr.nice = nice unless nice.nil?
  pr.prestart = prestart unless prestart.nil?
  pr.program = program
  pr.args = args unless args.empty?
  pr.log_directory = log_directory unless log_directory.nil?

  pr
end
# rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

def load_platform(v)
  Chef::Log.debug "[dropwizard_pleaserun] loading platform #{v}"
  platform_lib = "pleaserun/platform/#{v}"
  require platform_lib
  const = PleaseRun::Platform.constants.find { |c| c.to_s.casecmp(v).zero? }
  if const.nil?
    raise PlatformLoadError, "Could not find platform named '#{v}' after loading library " \
                             "'#{platform_lib}'. This is probably a bug."
  end
  return PleaseRun::Platform.const_get(const)
rescue LoadError => e
  raise PlatformLoadError, "Failed to find or load platform '#{v}'. This could be a typo or " \
                           " a bug. If it helps, the error is: #{e}"
end

def systemd_reload_enabled?(pleaserun_setup)
  require 'pleaserun/platform/systemd'
  pleaserun_setup.class == PleaseRun::Platform::Systemd &&
    systemd_reload_enabled && !pleaserun_setup.unit_path.to_s.empty?
end
