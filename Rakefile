# frozen_string_literal: true

require 'rake/testtask'

# Default task runs all tests and RuboCop
task default: :all

desc 'Run all tests with coverage'
Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.test_files = FileList['test/**/*test*.rb']
  t.verbose = true
end

desc 'Run tests without coverage'
task :test_no_coverage do
  ENV['COVERAGE'] = 'false'
  Rake::Task[:test].invoke
end

desc 'Run specific test file (e.g., rake test:node)'
namespace :test do
  desc 'Run node tests'
  Rake::TestTask.new(:node) do |t|
    t.libs << 'test'
    t.test_files = FileList['test/node/*test*.rb']
    t.verbose = true
  end

  desc 'Run nodes_collection tests'
  Rake::TestTask.new(:nodes_collection) do |t|
    t.libs << 'test'
    t.test_files = FileList['test/nodes_collection/*test*.rb']
    t.verbose = true
  end

  desc 'Run integration tests'
  Rake::TestTask.new(:integration) do |t|
    t.libs << 'test'
    t.test_files = FileList['test/integration/*test*.rb']
    t.verbose = true
  end

  desc 'Run utility tests (RuboCop, SimpleCov, etc.)'
  Rake::TestTask.new(:utilities) do |t|
    t.libs << 'test'
    t.test_files = FileList['test/utilities/*test*.rb']
    t.verbose = true
  end
end

desc 'Run RuboCop'
task :rubocop do
  sh 'bundle exec rubocop'
end

desc 'Run tests and RuboCop'
task all: %i[test rubocop]
