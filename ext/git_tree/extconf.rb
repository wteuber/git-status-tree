# frozen_string_literal: true

require 'mkmf'

find_executable('bash')
find_executable('git')
find_executable('make')

# Trick Rubygems into thinking the generated Makefile was executed
compile = File.join(Dir.pwd, "git_tree.#{RbConfig::CONFIG['DLEXT']}")
File.open(compile, 'w') {}

# Install "git tree"
puts `../../bin/git_add_alias_tree`

# Trick Rubygems into thinking the Makefile was executed
$makefile_created = true # rubocop:disable Style/GlobalVars
