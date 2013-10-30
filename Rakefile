require "bundler/setup"
task :default => [:list]

desc "Runs chefspec."
task :chefspec do
  sh "rspec ."
end

desc "Runs foodcritic."
task :foodcritic do
  sh "foodcritic ."
end

desc "Runs knife cookbook test against all the cookbooks."
task :knife_test do
  sh "knife cookbook test #{File.basename(File.expand_path("..", __FILE__))} -o ../."
end

desc "Starts vagrant and runs minitest"
task :vmstart do
  sh "vagrant up --destroy-on-error"
end

desc "Stops vagrant"
task :vmstop do
  sh "vagrant destroy -f"
end

desc "Run all tests"
task :test do
  [ :knife_test, :foodcritic, :chefspec, :vmstart, :vmstop ].each do |task|
    Rake::Task[task].execute
  end
end
