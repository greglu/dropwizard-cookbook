# encoding: UTF-8

include_recipe 'apt'
include_recipe 'java'

user node['dw_test']['user']

directory node['dw_test']['path'] do
  recursive true
  user node['dw_test']['user']
end

cookbook_file 'dw_test.jar' do
  path node['dw_test']['jar_file']
end

dropwizard 'dw_test' do
  arguments "server #{node['dw_test']['config']}"
  jar_file node['dw_test']['jar_file']
  user node['dw_test']['user']
end

service 'dw_test' do
  action :nothing
end

template node['dw_test']['config'] do
  source 'dw_test-config.yml.erb'
  mode 0644
  owner node['dw_test']['user']
  variables(node: node)

  subscribes :create, 'dropwizard[dw_test]', :delayed
  notifies :restart, 'service[dw_test]'
end

# For minitest purposes
package 'curl' do
  action :upgrade
end
