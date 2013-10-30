Vagrant.configure("2") do |config|
  config.vm.box = "precise64"
  config.vm.box_url = "http://files.vagrantup.com/precise64.box"

  config.berkshelf.enabled = true

  config.omnibus.chef_version = :latest

  config.cache.auto_detect = true

  config.vm.provision :chef_solo do |chef|
    chef.log_level = :debug
    chef.add_recipe "dropwizard"
  end
end
