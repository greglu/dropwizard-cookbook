dropwizard "dw-test" do
  user "test"
end

link "/opt/dw-test/dw-test.jar" do
  to "/vagrant/dw-test.jar"
end
