# frozen_string_literal: true

source 'https://rubygems.org'

# The gem itself supports Ruby >= 2.6 (the stock macOS system Ruby; see the
# gemspec). It has no RUNTIME dependencies: everything it needs is in the Ruby
# standard library, so it runs without the user installing any gems.
ruby '>= 2.6.0'

# The gems below are development tools only, and the locked versions (RuboCop,
# Bundler 4) need a modern Ruby. On Ruby 2.6, run the suite without Bundler:
# `ruby test/coverage.rb` uses only minitest (bundled with Ruby) and the stdlib
# `coverage` extension, which is how CI tests the 2.6 floor.
group :development, :test do
  gem 'minitest' # ships with Ruby; declared so `bundle exec rake test` resolves it
  gem 'rake'
  # RuboCop and its plugins are pinned exactly so new cops never appear without
  # an explicit upgrade. CI installs the same versions (.github/workflows/ci.yml);
  # keep them in sync. rubocop-minitest 0.40.0 is the newest release that
  # supports RuboCop 1.77.
  gem 'rubocop', '1.77.0', require: false
  gem 'rubocop-minitest', '0.40.0', require: false
  gem 'rubocop-rake', '0.7.1', require: false
end
