require "bundler/setup"
task :default => [:list]

desc "Lists all the tasks."
task :list do
  puts "Tasks: \n- #{(Rake::Task.tasks).join("\n- ")}"
end

desc "Runs chefspec."
task :chefspec do
  sh "rspec ."
end

desc "Runs foodcritic."
task :foodcritic do
  sh "foodcritic -I ../../foodcritic/* -f any ."
end

desc "Runs knife cookbook test against all the cookbooks."
task :knife_test do
  sh "knife cookbook test dropwizard -o ../."
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
