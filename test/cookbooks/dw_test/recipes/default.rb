dropwizard "dw-test" do
  user "test"
  # action :disable
end

link "/opt/dw-test/dw-test.jar" do
  to "/vagrant/dw-test.jar"
  only_if { ::File.exists?("/opt/dw-test") }
end
