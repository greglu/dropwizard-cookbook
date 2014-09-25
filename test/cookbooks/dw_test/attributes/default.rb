# encoding: UTF-8

##
# Java
##
default['java']['install_flavor'] = 'oracle'
default['java']['jdk_version'] = '7'
default['java']['oracle'] = { 'accept_oracle_download_terms' => true }

default['dw_test']['user'] = 'test'
default['dw_test']['path'] = '/opt/dw_test'
default['dw_test']['jar_file'] = "#{node['dw_test']['path']}/dw_test.jar"
default['dw_test']['config'] = "#{node['dw_test']['path']}/config.yml"
