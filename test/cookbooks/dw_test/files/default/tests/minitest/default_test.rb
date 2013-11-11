# encoding: UTF-8

require 'minitest/spec'

describe_recipe 'dw_test::default' do

  include MiniTest::Chef::Assertions
  include MiniTest::Chef::Context
  include MiniTest::Chef::Resources

  it 'creates the application user' do
    user('test').must_exist
  end

  it 'creates the application directory' do
    directory('/opt/dw_test')
      .must_exist
      .with(:owner, 'test')
  end

  it 'creates the upstart script in /etc/init' do
    file('/etc/init/dw_test.conf')
      .must_exist
      .with(:owner, 'root')
  end

  it 'creates the upstart script symlink in /etc/init.d' do
    if node[:platform] == 'ubuntu'
      link('/etc/init.d/dw_test')
        .must_exist
        .with(:link_type, :symbolic)
        .and(:to, '/lib/init/upstart-job')
    end
  end

  it 'creates the application config file' do
    file('/opt/dw_test/config.yml')
      .must_exist
      .with(:owner, 'test')
  end

  describe 'upstart script' do
    let(:config) { file('/etc/init/dw_test.conf') }

    it { config.must_include '/opt/dw_test' }

    it { config.must_include 'dw_test.jar' }

    it { config.must_include '/opt/dw_test/config.yml' }

    it 'is recognized as a service' do
      assert_sh 'status dw_test'
    end

    it 'in /etc/init.d is recognized as a sevice' do
      assert_sh '/etc/init.d/dw_test status' if node[:platform] == 'ubuntu'
    end
  end

  describe 'application configuration' do
    let(:config) { file('/opt/dw_test/config.yml') }

    it { config.must_include 'port: 8010' }

    it { config.must_include 'user: test' }

    it { config.must_include 'message: dw_test message' }
  end

  describe 'application service' do

    it 'is started up and serving requests' do
      time_before = Time.now.to_i

      # Sometimes a race condition can occur where the Java service is
      # in the process of starting up while Chef begins its minitest
      # run. This is a small loop that waits for up to 3 seconds
      # for the Java process to start accepting HTTP requests.
      while (Time.now.to_i - time_before) < 3
        break if system('curl http://localhost:8080 2>&1')
        sleep 0.5
      end

      output = assert_sh('curl http://localhost:8080')

      # The following expected message is set in the dw_test-config.yml.erb
      # template, so this verifies that the small server simulating
      # a dropwizard application receives the correct config file.
      assert_includes output, 'dw_test message'
    end

  end

end
