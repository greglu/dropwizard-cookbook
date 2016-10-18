source 'https://supermarket.getchef.com'

metadata

cookbook 'pleaserun'

group :test, :integration do
  cookbook 'dw_test', :path => './test/cookbooks/dw_test'
  cookbook 'apt'
  cookbook 'java'
end

group :integration do
  cookbook 'minitest-handler'
end
