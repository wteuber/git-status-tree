# frozen_string_literal: true

source 'https://rubygems.org'

# Supported Ruby floor: 2.6 (the stock macOS system Ruby). Any dependency added
# here must keep publishing a version whose required_ruby_version still allows
# 2.6, or the no-install-needed story on macOS breaks.
ruby '>= 2.6.0'

# git-status-tree has no RUNTIME dependencies: everything it needs is in the
# Ruby standard library, so the tool runs on the stock macOS system Ruby without
# the user installing Ruby or any gems. The gems below are development/CI tools
# only -- the test suite runs on minitest (bundled with Ruby) and measures
# coverage with the stdlib `coverage` extension (see test/coverage.rb), so it
# needs no gem install on the 2.6 floor.
group :development, :test do
  gem 'minitest' # ships with Ruby; declared so `bundle exec rake test` resolves it
  gem 'rake'
  gem 'rubocop', require: false
end
