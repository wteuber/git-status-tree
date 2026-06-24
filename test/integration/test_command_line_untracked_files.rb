# frozen_string_literal: true

require_relative '../test_helper'
require 'tempfile'
require 'tmpdir'

class TestCommandLineUntrackedFiles < Minitest::Test
  def setup
    @original_dir = Dir.pwd
    @test_dir = Dir.mktmpdir
    Dir.chdir(@test_dir)
    system('git init', out: File::NULL, err: File::NULL)

    FileUtils.mkdir_p('src')
    File.write('src/main.rb', 'puts "hello"')
    File.write('src/helper.rb', 'puts "help"')
  end

  def teardown
    Dir.chdir(@original_dir)
    FileUtils.rm_rf(@test_dir)
  end

  def test_untracked_files_long_option
    output = `#{File.join(__dir__, '../../bin/git-status-tree')} --untracked-files`
    assert_match(/└── \e\[1;34msrc\e\[0m$/, output)
    assert_match(/main\.rb \(\?\)/, output)
    assert_match(/helper\.rb \(\?\)/, output)
  end

  def test_untracked_files_short_option
    output = `#{File.join(__dir__, '../../bin/git-status-tree')} -u`
    assert_match(/main\.rb \(\?\)/, output)
    assert_match(/helper\.rb \(\?\)/, output)
  end

  def test_without_option_only_shows_directory
    output = `#{File.join(__dir__, '../../bin/git-status-tree')}`
    # Default git status reports the untracked directory as a single entry
    assert_match(/src \(\?\)/, output)
    assert_not_match(/main\.rb/, output)
    assert_not_match(/helper\.rb/, output)
  end
end
