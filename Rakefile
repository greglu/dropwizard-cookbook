require 'bundler'
Bundler.setup

require 'rake'
require 'foodcritic'
require 'rspec/core/rake_task'


task :default => [:spec]

RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = "./test/spec{,/*/**}/*_spec.rb"
  t.ruby_opts = "-I./test/spec"
end

FoodCritic::Rake::LintTask.new do |t|
  t.options = {:fail_tags => ['correctness']}
end

desc "Runs knife cookbook test against all the cookbooks"
task :knife_test do
  sh "knife cookbook test #{File.basename(File.expand_path("..", __FILE__))} -o ../."
end

# desc "Starts vagrant and runs minitest"
# task :vmstart do
#   sh "vagrant up --destroy-on-error"
# end

# desc "Stops vagrant"
# task :vmstop do
#   sh "vagrant destroy -f"
# end

# desc "Run all tests"
# task :test do
#   [ :knife_test, :foodcritic, :spec ].each do |task|
#     Rake::Task[task].execute
#   end
# end
