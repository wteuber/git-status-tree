# frozen_string_literal: true

# Measures line coverage of the library (lib/ and src/) while running the whole
# test suite, using only the Ruby standard library's `coverage` extension -- so
# it adds no gem dependency and runs on the 2.6 support floor. Exits non-zero if
# coverage falls below THRESHOLD.
#
#   ruby test/coverage.rb
require 'coverage'

THRESHOLD = 100.0
MEASURED_DIRS = %w[lib src].map { |dir| File.expand_path("../#{dir}", __dir__) }

Coverage.start

# Register the reporter BEFORE loading the tests. minitest/autorun (pulled in
# by test_helper) installs its own at_exit hook to run the suite; at_exit hooks
# fire last-in-first-out, so registering ours first means it runs last -- after
# the suite has finished and coverage has been recorded.
at_exit do
  result = Coverage.result
  covered = 0
  total = 0
  report = []

  result.each do |path, counts|
    next unless MEASURED_DIRS.any? { |dir| path.start_with?(dir) }

    executable = counts.compact
    total += executable.size
    covered += executable.count(&:positive?)
    uncovered = counts.each_index.select { |i| counts[i]&.zero? }.map { |i| i + 1 }
    report << format('  %<file>-22s %<covered>3d/%<total>-3d%<note>s',
                     file: File.basename(path),
                     covered: executable.count(&:positive?),
                     total: executable.size,
                     note: uncovered.empty? ? '' : "  uncovered lines: #{uncovered.join(', ')}")
  end

  percent = total.zero? ? 100.0 : covered.to_f / total * 100
  warn ''
  warn "Library line coverage: #{format('%.2f', percent)}% (#{covered}/#{total})"
  report.sort.each { |line| warn line }

  if percent < THRESHOLD
    warn ''
    warn "FAILED: coverage #{format('%.2f', percent)}% is below the #{THRESHOLD}% threshold."
    exit false
  end
end

Dir[File.join(__dir__, '**', 'test_*.rb')]
  .reject { |file| File.basename(file) == 'test_helper.rb' }
  .sort
  .each { |file| require file }
