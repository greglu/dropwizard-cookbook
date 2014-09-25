# encoding: UTF-8

require 'berkshelf'
require 'chefspec'
require 'chefspec/berkshelf'

RSpec.configure do |config|
  config.expect_with(:rspec) { |c| c.syntax = :expect }
  config.tty = true
end
