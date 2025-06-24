# frozen_string_literal: true

require 'test/unit'

class TestSimpleCov < Test::Unit::TestCase
  def test_simplecov_is_running
    if ENV['COVERAGE'] != 'false'
      assert(defined?(SimpleCov), 'SimpleCov should be loaded')
      assert(SimpleCov.running, 'SimpleCov should be running')
      puts "\nSimpleCov: Code coverage is being tracked ✓"
    else
      puts "\nSimpleCov: Code coverage disabled (COVERAGE=false)"
    end
  end
end
