site :opscode

metadata

cookbook 'apt'
cookbook 'java'

group :test, :integration do
  cookbook "dw_test", :path => "./test/cookbooks/dw_test"
end

group :integration do
  cookbook "minitest-handler"
end
