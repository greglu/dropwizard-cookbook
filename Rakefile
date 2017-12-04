# frozen_string_literal: true

require 'bundler/setup'
require 'rake'
require 'rspec/core/rake_task'
require 'foodcritic'
require 'rubocop/rake_task'

task default: [:test]

RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = '--default-path ./test/spec --color'
  t.pattern = '*_spec.rb'
end

FoodCritic::Rake::LintTask.new

RuboCop::RakeTask.new(:rubocop) do |task|
  task.patterns = ['{providers,resources,templates,test}/**/*.rb', '*.rb']
end

desc 'Runs knife cookbook test against all the cookbooks'
task :knife_test do
  sh "knife cookbook test #{File.basename(File.expand_path('..', __FILE__))} -o ../."
end

desc 'Run all tests'
task :test do
  %i[foodcritic spec rubocop].each do |task|
    Rake::Task[task].invoke
  end
end
