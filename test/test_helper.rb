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

    # assert_path_exists (preferred by rubocop-minitest) is missing from the
    # minitest bundled with Ruby 2.6; define it there. The cops are disabled
    # because this IS the fallback implementation (their autocorrection would
    # make it call itself).
    unless method_defined?(:assert_path_exists)
      def assert_path_exists(path, msg = nil)
        # rubocop:disable Minitest/AssertPathExists, Minitest/AssertWithExpectedArgument
        assert(File.exist?(path), msg || "Expected path '#{path}' to exist")
        # rubocop:enable Minitest/AssertPathExists, Minitest/AssertWithExpectedArgument
      end
    end
  end
end

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
$LOAD_PATH.unshift File.expand_path('../src', __dir__)

require 'tmpdir'
require 'fileutils'

# Isolate the suite from the developer's git configuration. git-status-tree
# reads (and some tests write and unset) the *global* status-tree.* settings,
# so point git's global config at a throwaway file (GIT_CONFIG_GLOBAL, git
# 2.32+) and skip the system config: the real global config is never touched,
# and output-format assertions don't depend on a custom indent. Only git config
# is redirected; HOME (gems, Bundler settings) is left alone. Child processes
# (bin/git-status-tree, git) inherit this environment.
TEST_GIT_CONFIG_DIR = Dir.mktmpdir('git-status-tree-gitconfig')
ENV['GIT_CONFIG_GLOBAL'] = File.join(TEST_GIT_CONFIG_DIR, 'gitconfig')
ENV['GIT_CONFIG_NOSYSTEM'] = '1'
# Not at_exit: that would run before minitest/autorun's own at_exit hook (LIFO)
# and delete the directory before the suite starts.
Minitest.after_run { FileUtils.rm_rf(TEST_GIT_CONFIG_DIR) }

require 'bash_color'
require 'node_collapsing'
require 'node'
require 'nodes_collection'
require 'git_status_tree'
require 'version'
