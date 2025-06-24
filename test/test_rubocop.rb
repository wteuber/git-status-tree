# frozen_string_literal: true

require 'test/unit'
require 'open3'

class TestRuboCop < Test::Unit::TestCase
  def test_code_style
    puts "\nRunning RuboCop..."
    stdout, _stderr, status = Open3.capture3('bundle', 'exec', 'rubocop')

    if status.success?
      puts 'RuboCop: All files pass code style checks ✓'
    else
      puts "\nRuboCop violations found:"
      puts stdout
    end

    assert(status.success?, "RuboCop found code style violations. Run 'bundle exec rubocop' to see details.")
  end
end
