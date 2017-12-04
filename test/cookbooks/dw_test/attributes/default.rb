# frozen_string_literal: true

##
# Java
##
default['java']['install_flavor'] = 'openjdk'
default['java']['jdk_version'] = '8'

default['dw_test']['user'] = 'test'
default['dw_test']['path'] = '/opt/dw_test'
default['dw_test']['jar_file'] = "#{node['dw_test']['path']}/dw_test.jar"
default['dw_test']['config'] = "#{node['dw_test']['path']}/config.yml"
default['dw_test']['jvm_options'] = '-Xms32m -Xmx64m'
default['dw_test']['init_platform'] = ''
