site :opscode

metadata

cookbook 'apt'
cookbook 'java'

group :integration do
  cookbook "dw-test", :path => "./test/cookbooks/dw_test"
  cookbook "minitest-handler"
end
