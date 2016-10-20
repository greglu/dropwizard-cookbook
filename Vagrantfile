Vagrant.configure('2') do |config|
  config.vm.box = 'opscode-ubuntu-14.04'
  config.vm.box_url = 'http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_ubuntu-14.04_chef-provisionerless.box'

  # config.vm.box = 'opscode-ubuntu-12.10'
  # config.vm.box_url = 'https://opscode-vm-bento.s3.amazonaws.com/vagrant/opscode_ubuntu-12.10_provisionerless.box'

  # config.vm.box = 'opscode-centos-6.4'
  # config.vm.box_url = 'http://opscode-vm-bento.s3.amazonaws.com/vagrant/opscode_centos-6.4_provisionerless.box'

  config.berkshelf.enabled = true
  config.omnibus.chef_version = :latest

  config.vm.provision :chef_solo do |chef|
    chef.log_level = :debug
    chef.add_recipe 'dw_test'
    chef.add_recipe 'minitest-handler'
  end
end
