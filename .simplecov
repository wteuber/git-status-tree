# frozen_string_literal: true

SimpleCov.configure do
  # Set minimum coverage percentage
  minimum_coverage 85

  # Set a more reasonable per-file threshold
  minimum_coverage_by_file 40

  # Refuse to run tests if coverage drops below threshold
  refuse_coverage_drop

  # Maximum coverage drop allowed
  maximum_coverage_drop 2

  # Groups for better organization in coverage report
  add_group 'Source', 'src/'
  add_group 'Libraries', 'lib/'
  add_group 'Binaries', 'bin/'

  # Filters
  add_filter '/test/'
  add_filter '/ext/'
  add_filter 'vendor'

  # Use Rails-style coverage format
  formatter SimpleCov::Formatter::HTMLFormatter
end
