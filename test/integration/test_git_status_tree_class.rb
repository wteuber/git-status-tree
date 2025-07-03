# frozen_string_literal: true

require_relative '../test_helper'

class TestGitStatusTreeClass < Test::Unit::TestCase
  def setup
    @original_dir = Dir.pwd
    @test_dir = Dir.mktmpdir('git_test')
    Dir.chdir(@test_dir)
    `git init --quiet`
    `git config user.email "test@example.com"`
    `git config user.name "Test User"`
  end

  def teardown
    Dir.chdir(@original_dir)
    FileUtils.rm_rf(@test_dir)
  end

  def test_initialize_clean_repository
    tree = GitStatusTree.new
    assert_not_nil(tree)
    assert_equal([], tree.files)
    assert_equal([], tree.nodes)
    assert_nil(tree.tree)
  end

  def test_to_s_clean_repository
    tree = GitStatusTree.new
    assert_equal('(working directory clean)', tree.to_s)
  end

  def test_initialize_with_untracked_file
    File.write('test.txt', 'content')
    tree = GitStatusTree.new
    assert_equal(1, tree.files.length)
    assert_equal(1, tree.nodes.length)
    assert_not_nil(tree.tree)
  end

  def test_to_s_with_files
    File.write('test.txt', 'content')
    tree = GitStatusTree.new
    output = tree.to_s
    assert_match(/test\.txt/, output)
  end

  def test_initialize_with_custom_indent
    GitStatusTree.new(indent: 8)
    assert_equal(8, Node.indent)
  end

  def test_indent_minimum
    GitStatusTree.new(indent: 1)
    assert_equal(2, Node.indent)
  end

  def test_indent_maximum
    GitStatusTree.new(indent: 20)
    assert_equal(10, Node.indent)
  end

  def test_indent_from_git_config
    `git config --global status-tree.indent 6`
    GitStatusTree.new
    assert_equal(6, Node.indent)
  ensure
    `git config --global --unset status-tree.indent 2>/dev/null`
  end

  def test_indent_default_when_no_config
    `git config --global --unset status-tree.indent 2>/dev/null`
    GitStatusTree.new
    assert_equal(4, Node.indent)
  end

  def test_collapse_from_git_config_true
    `git config --global status-tree.collapse true`
    GitStatusTree.new
    assert_equal(true, Node.collapse_dirs)
  ensure
    `git config --global --unset status-tree.collapse 2>/dev/null`
  end

  def test_collapse_from_git_config_false
    `git config --global status-tree.collapse false`
    GitStatusTree.new
    assert_equal(false, Node.collapse_dirs)
  ensure
    `git config --global --unset status-tree.collapse 2>/dev/null`
  end

  def test_collapse_default_when_no_config
    `git config --global --unset status-tree.collapse 2>/dev/null`
    GitStatusTree.new
    assert_equal(false, Node.collapse_dirs)
  end

  def test_collapse_command_line_overrides_config
    `git config --global status-tree.collapse false`
    GitStatusTree.new(collapse: true)
    assert_equal(true, Node.collapse_dirs)
  ensure
    `git config --global --unset status-tree.collapse 2>/dev/null`
  end

  def test_multiple_files_and_directories
    Dir.mkdir('src')
    File.write('src/main.rb', 'puts "hello"')
    File.write('README.md', '# Test')
    `git add README.md`

    tree = GitStatusTree.new
    output = tree.to_s

    assert_match(/src/, output)
    # When directory is untracked, individual files inside aren't shown
    assert_match(/README\.md/, output)
  end

  def test_renamed_file_same_directory
    Dir.mkdir('src')
    File.write('src/old.rb', 'content')
    `git add src/old.rb`
    `git commit -m "Add old.rb"`

    File.rename('src/old.rb', 'src/new.rb')
    `git add .`

    tree = GitStatusTree.new
    output = tree.to_s

    assert_match(/old\.rb -> new\.rb/, output)
    assert_match(/\(R\+\)/, output)
  end

  def test_renamed_file_cross_directory
    Dir.mkdir('src')
    Dir.mkdir('lib')
    File.write('src/file.rb', 'content')
    `git add src/file.rb`
    `git commit -m "Add file.rb"`

    File.rename('src/file.rb', 'lib/file.rb')
    `git add .`

    tree = GitStatusTree.new
    output = tree.to_s

    assert_match(%r{file\.rb -> lib/file\.rb}, output)
    assert_match(/\(R\+\)/, output)
  end

  def test_renamed_file_root_directory
    File.write('old_name.txt', 'content')
    `git add old_name.txt`
    `git commit -m "Add old_name.txt"`

    File.rename('old_name.txt', 'new_name.txt')
    `git add .`

    tree = GitStatusTree.new
    output = tree.to_s

    assert_match(/old_name\.txt -> new_name\.txt/, output)
    assert_match(/\(R\+\)/, output)
  end
end
