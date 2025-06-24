# frozen_string_literal: true

require 'test/unit'
require 'open3'

class TestCommandLine < Test::Unit::TestCase
  def setup
    @executable = File.join(File.dirname(__FILE__), '..', 'bin', 'git-status-tree')
  end

  def test_version_flag_long
    stdout, stderr, status = Open3.capture3(@executable, '--version')
    assert_equal(0, status.exitstatus)
    assert_equal('', stderr)
    assert_match(/\Agit-status-tree \d+\.\d+\.\d+\n\z/, stdout)
  end

  def test_version_flag_short
    stdout, stderr, status = Open3.capture3(@executable, '-v')
    assert_equal(0, status.exitstatus)
    assert_equal('', stderr)
    assert_match(/\Agit-status-tree \d+\.\d+\.\d+\n\z/, stdout)
  end

  def test_help_flag_long
    stdout, stderr, status = Open3.capture3(@executable, '--help')
    assert_equal(0, status.exitstatus)
    assert_equal('', stderr)
    assert_match(/Usage: git-status-tree \[options\]/, stdout)
    assert_match(/-v, --version\s+Show version/, stdout)
    assert_match(/-h, --help\s+Show this help message/, stdout)
  end

  def test_help_flag_short
    stdout, stderr, status = Open3.capture3(@executable, '-h')
    assert_equal(0, status.exitstatus)
    assert_equal('', stderr)
    assert_match(/Usage: git-status-tree \[options\]/, stdout)
  end

  def test_invalid_option
    stdout, _stderr, status = Open3.capture3(@executable, '--invalid-option')
    assert_equal(1, status.exitstatus)
    assert_match(/Error: invalid option: --invalid-option/, stdout)
    assert_match(/Usage: git-status-tree \[options\]/, stdout)
  end

  def test_multiple_options
    # Version flag should take precedence and exit
    stdout, _stderr, status = Open3.capture3(@executable, '--version', '--help')
    assert_equal(0, status.exitstatus)
    assert_match(/\Agit-status-tree \d+\.\d+\.\d+\n\z/, stdout)
  end

  def test_no_options_runs_normally
    # Run in the project directory where git is initialized
    Dir.chdir(File.join(File.dirname(__FILE__), '..')) do
      stdout, stderr, status = Open3.capture3(@executable)
      assert_equal(0, status.exitstatus)
      assert_equal('', stderr)
      # Should output something - either the tree or "(working directory clean)"
      assert(!stdout.empty?)
    end
  end
end
