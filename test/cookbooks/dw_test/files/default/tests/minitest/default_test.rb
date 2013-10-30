require 'minitest/spec'


describe_recipe "dw_test::default" do

  include MiniTest::Chef::Assertions
  include MiniTest::Chef::Context
  include MiniTest::Chef::Resources


  it "creates the application user" do
    user("test").must_exist
  end

  it "creates the application directory" do
    directory("/opt/dw_test")
      .must_exist
      .with(:owner, "test")
  end

  it "creates the upstart script in /etc/init" do
    file("/etc/init/dw_test.conf")
      .must_exist
      .with(:owner, "root")
  end

  it "creates the upstart script symlink in /etc/init.d" do
    link("/etc/init.d/dw_test")
      .must_exist
      .with(:link_type, :symbolic)
      .and(:to, "/lib/init/upstart-job")
  end

  it "creates the application config file" do
    file("/opt/dw_test/config.yml")
      .must_exist
      .with(:owner, "test")
  end


  describe "upstart script" do
    let(:config) { file("/etc/init/dw_test.conf") }

    it { config.must_include "/opt/dw_test" }

    it { config.must_include "dw_test.jar" }

    it { config.must_include "/opt/dw_test/config.yml" }

    it "is recognized as a service" do
      result = assert_sh('service dw_test status')
      assert_includes result, "dw_test stop/waiting"
    end

    it "in /etc/init.d works as well" do
      result = assert_sh('/etc/init.d/dw_test status')
      assert_includes result, "dw_test stop/waiting"
    end
  end

  describe "application configuration" do
    let(:config) { file("/opt/dw_test/config.yml") }

    it { config.must_include "port: 8010" }

    it { config.must_include "user: test" }
  end

end
