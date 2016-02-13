require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

RuboCop::RakeTask.new
RSpec::Core::RakeTask.new(:spec)

task :ci do
  # Commenting out Rubocop as part of the CI build temporarily
  # because TravisCI is not respecting the .rubocop_todo.yml
  # You can and should still run rubocop in your editor or
  # from the command line manually.
  # Rake::Task['rubocop'].invoke
  Rake::Task['spec'].invoke
end

task default: :ci
