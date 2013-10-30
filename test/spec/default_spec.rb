require 'spec_helper'

describe 'dropwizard::default' do

  context 'usual' do
    let(:chef_run) do
      ChefSpec::ChefRunner.new(platform: 'ubuntu', version: '12.04').converge('dropwizard::default')
    end

    it 'installs the dropwizard resource' do
      expect(chef_run).to install_dropwizard('dw-test')
    end

  end

end
