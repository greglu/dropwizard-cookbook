# frozen_string_literal: true

require 'spec_helper'

describe 'dw_test::default' do
  context 'install' do
    cached(:chef_run) do
      # The dropwizard resource outputs a warning if the jar isn't present. This
      # silence_stream suppresses that message from appearing during spec runs.
      silence_stream(STDOUT) do
        ChefSpec::ServerRunner.new(
          platform: 'ubuntu', version: '16.04', step_into: %w[dropwizard dropwizard_pleaserun]
        ).converge(described_recipe)
      end
    end

    it 'creates the app user' do
      expect(chef_run).to create_user('test')
    end

    it 'creates the app directory' do
      expect(chef_run).to create_directory('/opt/dw_test').with(user: 'test')
    end

    it 'creates the dropwizard_pleaserun resource' do
      expect(chef_run).to create_dropwizard_pleaserun('dw_test')
    end

    it 'should install the chef_gem pleaserun' do
      expect(chef_run).to install_chef_gem('pleaserun')
    end
  end
end
