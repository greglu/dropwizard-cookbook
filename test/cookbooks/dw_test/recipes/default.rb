dropwizard "dw_test" do
  arguments "server #{node[:dw_test][:config]}"
  user node[:dw_test][:user]
end

template node[:dw_test][:config] do
  source "dw_test-config.yml.erb"
  mode 0644
  owner node[:dw_test][:user]
  group node[:dw_test][:user]
  variables(:node => node)

  subscribes :create, "dropwizard[dw_test]", :delayed
end
