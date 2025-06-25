# frozen_string_literal: true

# Initialize SimpleCov only once, early in the test run
return if defined?(@simplecov_loaded)

@simplecov_loaded = true

unless ENV['COVERAGE'] == 'false'
  require 'simplecov'
  require 'simplecov-json'

  SimpleCov.configure do
    minimum_coverage 100
    refuse_coverage_drop

    add_group 'Source', 'src/'
    add_group 'Libraries', 'lib/'
    add_group 'Binaries', 'bin/'

    add_filter '/test/'
    add_filter '/ext/'
    add_filter 'vendor'

    formatters = [
      SimpleCov::Formatter::HTMLFormatter,
      SimpleCov::Formatter::JSONFormatter
    ]
    formatter SimpleCov::Formatter::MultiFormatter.new(formatters)
  end

  SimpleCov.start
end
