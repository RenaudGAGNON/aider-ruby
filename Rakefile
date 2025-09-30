require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

require 'rubocop/rake_task'
RuboCop::RakeTask.new

task default: :spec

desc 'Run all tests and linting'
task ci: %i[spec rubocop]

desc 'Build and install the gem'
task install: :build do
  sh 'gem install ./aider-ruby-*.gem'
end

desc 'Clean build artifacts'
task :clean do
  sh 'rm -f aider-ruby-*.gem'
end
