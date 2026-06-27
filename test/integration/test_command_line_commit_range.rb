# frozen_string_literal: true

require_relative '../test_helper'
require 'open3'

# Integration tests for the two-commit history view: `git tree <c1> <c2>` and
# the single-token `git tree A..B` range form.
class TestCommandLineCommitRange < Minitest::Test
  def setup
    @bin = File.join(__dir__, '..', '..', 'bin', 'git-status-tree')
    @original_dir = Dir.pwd
    @test_dir = Dir.mktmpdir('git_tree_range')
    Dir.chdir(@test_dir)
    `git init --quiet`
    `git config user.email "test@example.com"`
    `git config user.name "Test User"`

    File.write('base.rb', "base\n")
    `git add .`
    `git commit -m "c1" --quiet`
    @c1 = `git rev-parse HEAD`.strip

    File.write('added.rb', "added\n")
    `git add -A`
    `git commit -m "c2" --quiet`
    @c2 = `git rev-parse HEAD`.strip
  end

  def teardown
    Dir.chdir(@original_dir)
    FileUtils.rm_rf(@test_dir)
  end

  def run_bin(*args)
    Open3.capture3(@bin, *args)
  end

  def test_two_commits_show_diff_between_them
    stdout, stderr, status = run_bin(@c1, @c2)
    assert_equal(0, status.exitstatus)
    assert_equal('', stderr)
    assert_match(/added\.rb \(A\)/, stdout)
  end

  def test_reversed_order_flips_add_to_delete
    stdout, _stderr, status = run_bin(@c2, @c1)
    assert_equal(0, status.exitstatus)
    assert_match(/added\.rb \(D\)/, stdout)
  end

  def test_range_token_equivalent_to_two_args
    stdout, _stderr, status = run_bin("#{@c1}..#{@c2}")
    assert_equal(0, status.exitstatus)
    assert_match(/added\.rb \(A\)/, stdout)
  end

  def test_symmetric_difference_range_rejected
    stdout, stderr, status = run_bin("#{@c1}...#{@c2}")
    assert_equal(1, status.exitstatus)
    assert_equal('', stdout)
    assert_match(/'\.\.\.' range is not supported/, stderr)
  end

  def test_rename_across_dirs_renders_arrow_with_path
    FileUtils.mkdir_p('lib')
    `git mv base.rb lib/base.rb`
    `git commit -m "c3" --quiet`
    c3 = `git rev-parse HEAD`.strip

    stdout, _stderr, status = run_bin(@c2, c3)
    assert_equal(0, status.exitstatus)
    assert_match(%r{base\.rb -> lib/base\.rb \(R\)}, stdout)
  end

  def test_indent_option_applies_in_range_mode
    FileUtils.mkdir_p('deep')
    File.write('deep/file.rb', "x\n")
    `git add -A`
    `git commit -m "c3" --quiet`
    c3 = `git rev-parse HEAD`.strip

    stdout, _stderr, status = run_bin('-i', '8', @c2, c3)
    assert_equal(0, status.exitstatus)
    assert_match(/deep/, stdout)
    # An 8-space indent leaves a wider gutter under the directory branch.
    assert_match(/\e\[0;36m.*file\.rb \(A\)/, stdout)
  end
end
