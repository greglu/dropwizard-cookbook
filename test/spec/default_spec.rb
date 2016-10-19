# encoding: UTF-8

require 'spec_helper'

describe 'dw_test::default' do
  context 'install' do
    let(:chef_run) do
      # The dropwizard LWRP outputs a warning if the jar isn't present. This
      # silence_stream suppresses that message from appearing during spec runs.
      silence_stream(STDOUT) do
        ChefSpec::ServerRunner.new(
          platform: 'ubuntu', version: '12.04', step_into: ['dropwizard']
        ).converge(described_recipe)
      end
    end

    before do
      stub_command('test -f /lib/init/upstart-job && test -d /etc/init.d')
        .and_return(true)
    end

    it 'should include java recipe' do
      expect(chef_run).to include_recipe('pleaserun')
    end

    it 'creates the app user' do
      expect(chef_run).to create_user('test')
    end

    it 'creates the app directory' do
      expect(chef_run).to create_directory('/opt/dw_test').with(user: 'test')
    end

    it 'creates an upstart script' do
      expect(chef_run).to create_pleaserun('dw_test')
    end

    it 'creates a symlink to /etc/init.d for backwards compatibitity' do
      expect(chef_run).to create_link('/etc/init.d/dw_test')
        .with(to: '/lib/init/upstart-job')
    end

    it 'does not create a symlink to /etc/init.d if it does not exist' do
      stub_command('test -f /lib/init/upstart-job && test -d /etc/init.d')
        .and_return(false)

      expect(chef_run).to_not create_link('/etc/init.d/dw_test')
    end
  end
end
