# frozen_string_literal: true

require_relative '../test_helper'
require 'open3'

# Integration tests for the single-commit history view: `git tree <commit>`.
class TestCommandLineCommit < Minitest::Test
  def setup
    @bin = File.join(__dir__, '..', '..', 'bin', 'git-status-tree')
    @original_dir = Dir.pwd
    @test_dir = Dir.mktmpdir('git_tree_commit')
    Dir.chdir(@test_dir)
    `git init --quiet`
    `git config user.email "test@example.com"`
    `git config user.name "Test User"`
  end

  def teardown
    Dir.chdir(@original_dir)
    FileUtils.rm_rf(@test_dir)
  end

  def run_bin(*args)
    Open3.capture3(@bin, *args)
  end

  def test_single_commit_shows_added_modified_deleted
    FileUtils.mkdir_p('src')
    File.write('src/keep.rb', "v1\n")
    File.write('drop.rb', "bye\n")
    `git add .`
    `git commit -m "c1" --quiet`

    File.write('src/keep.rb', "v2\n")
    File.write('new.rb', "hi\n")
    File.delete('drop.rb')
    `git add -A`
    `git commit -m "c2" --quiet`

    stdout, stderr, status = run_bin('HEAD')
    assert_equal(0, status.exitstatus)
    assert_equal('', stderr)
    assert_match(/keep\.rb \(M\)/, stdout)
    assert_match(/new\.rb \(A\)/, stdout)
    assert_match(/drop\.rb \(D\)/, stdout)
    # Commit-mode entries render cyan with no staged "+" suffix.
    assert_match(/\e\[0;36m.*keep\.rb \(M\)/, stdout)
    assert_no_match(/\(M\+\)/, stdout)
  end

  def test_rename_within_commit_shows_arrow
    File.write('old.rb', "content\n")
    `git add .`
    `git commit -m "c1" --quiet`

    File.rename('old.rb', 'renamed.rb')
    `git add -A`
    `git commit -m "c2" --quiet`

    stdout, _stderr, status = run_bin('HEAD')
    assert_equal(0, status.exitstatus)
    assert_match(/old\.rb -> renamed\.rb \(R\)/, stdout)
  end

  def test_root_commit_lists_all_files_as_added
    FileUtils.mkdir_p('src')
    File.write('src/a.rb', "a\n")
    File.write('b.rb', "b\n")
    `git add .`
    `git commit -m "root" --quiet`

    stdout, _stderr, status = run_bin('HEAD')
    assert_equal(0, status.exitstatus)
    assert_match(/a\.rb \(A\)/, stdout)
    assert_match(/b\.rb \(A\)/, stdout)
  end

  def test_commit_with_no_changes_reports_no_changes
    File.write('a.rb', "a\n")
    `git add .`
    `git commit -m "c1" --quiet`

    # Comparing a commit to itself yields an empty diff.
    stdout, _stderr, status = run_bin('HEAD', 'HEAD')
    assert_equal(0, status.exitstatus)
    assert_equal("(no changes)\n", stdout)
  end

  def test_invalid_revision_exits_non_zero
    stdout, stderr, status = run_bin('definitely-not-a-rev')
    refute_equal(0, status.exitstatus)
    assert_equal('', stdout)
    assert_match(/fatal: bad revision 'definitely-not-a-rev'/, stderr)
  end

  def test_three_args_rejected_with_usage
    stdout, stderr, status = run_bin('a', 'b', 'c')
    assert_equal(1, status.exitstatus)
    assert_equal('', stdout)
    assert_match(/accepts at most two commits/, stderr)
    assert_match(/Usage: git-status-tree/, stderr)
  end
end
