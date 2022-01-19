# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

RuboCop::RakeTask.new do |task|
  task.requires << 'rubocop-rspec'
end

RSpec::Core::RakeTask.new(:spec)

task :ci do
  Rake::Task['rubocop'].invoke
  Rake::Task['spec'].invoke
end

task default: :ci
