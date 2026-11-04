# frozen_string_literal: true

require 'mkmf'

find_executable('bash')
find_executable('git')
find_executable('make')

# There is nothing to compile: this "extension" only exists so RubyGems runs
# this script at install time. Create the placeholder library RubyGems expects
# the (no-op) build in ext/git_tree/Makefile to produce.
compile = File.join(Dir.pwd, "git_tree.#{RbConfig::CONFIG['DLEXT']}")
File.write(compile, '')

# Install "git tree"
puts `../../bin/git_add_alias_tree`

# Tell mkmf the Makefile already exists (the static ext/git_tree/Makefile)
$makefile_created = true # rubocop:disable Style/GlobalVars
