# frozen_string_literal: true

include_recipe 'java'

dropwizard 'dw_test' do
  config_file node['dw_test']['config']
  jar_file node['dw_test']['jar_file']
  user node['dw_test']['user']
  path node['dw_test']['path']
  jvm_options node['dw_test']['jvm_options']
  init_platform node['dw_test']['init_platform']
  action :install
end

# dropwizard 'dw_test' do
#   user node['dw_test']['user']
#   path node['dw_test']['path']
#   action :delete
# end

cookbook_file 'dw_test.jar' do
  path node['dw_test']['jar_file']
  notifies :install, 'dropwizard[dw_test]', :delayed
  notifies :restart, 'dropwizard[dw_test]', :delayed
end

template node['dw_test']['config'] do
  source 'dw_test-config.yml.erb'
  mode 0644
  owner node['dw_test']['user']
  variables(node: node)

  subscribes :create, 'dropwizard[dw_test]', :delayed
  notifies :restart, 'dropwizard[dw_test]', :delayed
end

# For minitest purposes
package 'curl' do
  action :upgrade
end
