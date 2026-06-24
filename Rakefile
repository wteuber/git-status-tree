# frozen_string_literal: true

require 'rake/testtask'

# Default task runs the test suite and RuboCop
task default: %i[test rubocop]

desc 'Run the test suite'
Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.test_files = FileList['test/**/test_*.rb'].exclude('test/test_helper.rb')
  t.verbose = true
end

# Stdlib-only coverage gate (no gem dependency, runs on the Ruby 2.6 floor).
# This is what CI runs; it loads the whole suite and fails below the threshold.
desc 'Run the test suite with the stdlib coverage gate'
task :coverage do
  ruby 'test/coverage.rb'
end

namespace :test do
  {
    node: 'test/node/test_*.rb',
    nodes_collection: 'test/nodes_collection/test_*.rb',
    integration: 'test/integration/test_*.rb'
  }.each do |name, glob|
    desc "Run #{name} tests"
    Rake::TestTask.new(name) do |t|
      t.libs << 'test'
      t.test_files = FileList[glob]
      t.verbose = true
    end
  end
end

desc 'Run RuboCop (Ruby 2.6 compatibility check)'
task :rubocop do
  sh 'bundle exec rubocop'
end
