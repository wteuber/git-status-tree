# frozen_string_literal: true

require 'minitest/autorun'

# test-unit compatibility shims: the suite is run on minitest -- the test
# framework bundled with every Ruby (2.6+) -- so it needs no gem install and
# runs on the stock macOS system Ruby. These map the handful of test/unit-only
# assertions still used by the suite onto their minitest equivalents.
module Minitest
  class Test
    alias assert_raise assert_raises
    alias assert_not_match refute_match
    alias assert_no_match refute_match
    alias assert_not_nil refute_nil

    # minitest has no assert_nothing_raised; a raised exception fails the test
    # on its own, so just run the block and record an assertion.
    def assert_nothing_raised(*)
      yield
      pass
    end
  end
end

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
$LOAD_PATH.unshift File.expand_path('../src', __dir__)

require 'tmpdir'
require 'fileutils'

# Isolate the suite from the developer's git configuration. git-status-tree
# reads (and some tests write and unset) the *global* status-tree.* settings,
# so point HOME at a throwaway directory: the real ~/.gitconfig is never
# touched, and output-format assertions don't depend on a custom indent.
# Child processes (bin/git-status-tree, git) inherit this environment.
TEST_HOME = Dir.mktmpdir('git-status-tree-home')
ENV['HOME'] = TEST_HOME
ENV.delete('XDG_CONFIG_HOME')
ENV['GIT_CONFIG_NOSYSTEM'] = '1'
# Not at_exit: that would run before minitest/autorun's own at_exit hook (LIFO)
# and delete HOME before the suite starts.
Minitest.after_run { FileUtils.rm_rf(TEST_HOME) }

require 'bash_color'
require 'node_collapsing'
require 'node'
require 'nodes_collection'
require 'git_status_tree'
require 'version'
