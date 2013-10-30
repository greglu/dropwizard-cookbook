Vagrant.configure("2") do |config|
  config.vm.box = "opscode-ubuntu-12.04"
  config.vm.box_url = "https://opscode-vm-bento.s3.amazonaws.com/vagrant/opscode_ubuntu-12.04_provisionerless.box"

  config.berkshelf.enabled = true

  config.omnibus.chef_version = :latest

  config.cache.auto_detect = true

  config.vm.provision :chef_solo do |chef|
    chef.log_level = :debug
    chef.add_recipe "dw_test"
    chef.add_recipe "minitest-handler"
  end
end
