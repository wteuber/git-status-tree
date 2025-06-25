# frozen_string_literal: true

require_relative '../test_helper'

class TestSimpleCov < Test::Unit::TestCase
  def test_simplecov_is_running
    if ENV['COVERAGE'] == 'false'
      puts "\nSimpleCov: Code coverage disabled (COVERAGE=false)"
    else
      assert(defined?(SimpleCov), 'SimpleCov should be loaded')
      assert(SimpleCov.running, 'SimpleCov should be running')
      puts "\nSimpleCov: Code coverage is being tracked ✓"
    end
  end
end
