# frozen_string_literal: true

require_relative '../test_helper'
require 'tempfile'
require 'tmpdir'

class TestCommandLineCollapse < Test::Unit::TestCase
  def setup
    @original_dir = Dir.pwd
    @test_dir = Dir.mktmpdir
    Dir.chdir(@test_dir)
    system('git init', out: File::NULL, err: File::NULL)
  end

  def teardown
    Dir.chdir(@original_dir)
    FileUtils.rm_rf(@test_dir)
  end

  def test_collapse_option_with_deeply_nested_structure
    # Create deeply nested structure
    FileUtils.mkdir_p('domains/foo/bar/module/module-api/src/main/java/com/company/api')
    FileUtils.mkdir_p('domains/foo/bar/module/module-impl/src/main/java/com/company/impl')

    File.write('domains/foo/bar/module/module-api/src/main/java/com/company/api/Service.java',
               'public class Service {}')
    File.write('domains/foo/bar/module/module-impl/src/main/java/com/company/impl/ServiceImpl.java',
               'public class ServiceImpl {}')

    system('git add .')

    # Test without collapse
    output_normal = `#{File.join(__dir__, '../../bin/git-status-tree')}`
    assert_match(/^\e\[1;34m\.\e\[0m$/, output_normal) # Root node with color codes
    assert_match(/└── \e\[1;34mdomains\e\[0m$/, output_normal)
    assert_match(/└── \e\[1;34mfoo\e\[0m$/, output_normal)
    assert_match(/└── \e\[1;34mbar\e\[0m$/, output_normal)
    assert_match(/└── \e\[1;34mmodule\e\[0m$/, output_normal)

    # Test with collapse
    output_collapsed = `#{File.join(__dir__, '../../bin/git-status-tree')} --collapse`
    assert_match(/^\e\[1;34m\.\e\[0m$/, output_collapsed) # Root node with color codes
    assert_match(%r{└── \e\[1;34mdomains/foo/bar/module\e\[0m$}, output_collapsed)
    # Now the files are included in the collapsed path
    assert_match(
      %r{├── \e\[1;34mmodule-api/src/main/java/com/company/api/\e\[0m\e\[0;32mService\.java \(A\+\)\e\[0m},
      output_collapsed
    )
    assert_match(
      %r{└── \e\[1;34mmodule-impl/src/main/java/com/company/impl/\e\[0m\e\[0;32mServiceImpl\.java \(A\+\)\e\[0m},
      output_collapsed
    )
  end

  def test_collapse_short_option
    FileUtils.mkdir_p('a/b/c')
    File.write('a/b/c/file.txt', 'content')
    system('git add .')

    output = `#{File.join(__dir__, '../../bin/git-status-tree')} -c`
    # Should show root node and collapsed path
    assert_match(/^\e\[1;34m\.\e\[0m$/, output)
    assert_match(%r{└── \e\[1;34ma/b/c/\e\[0m\e\[0;32mfile\.txt \(A\+\)\e\[0m}, output)
  end

  def test_collapse_with_mixed_content
    # Directory that should not collapse (has files and subdirs)
    FileUtils.mkdir_p('src/main')
    File.write('src/file.txt', 'content')
    File.write('src/main/Main.java', 'public class Main {}')

    # Directory that should collapse
    FileUtils.mkdir_p('test/unit/java/com/company')
    File.write('test/unit/java/com/company/Test.java', 'public class Test {}')

    system('git add .')

    output = `#{File.join(__dir__, '../../bin/git-status-tree')} --collapse`

    # Should show root node
    assert_match(/^\e\[1;34m\.\e\[0m$/, output)

    # src should not be collapsed because it contains both files and directories
    assert_match(/├── \e\[1;34msrc\e\[0m$/, output)
    assert_match(%r{│\s+├── \e\[1;34mmain/\e\[0m\e\[0;32mMain\.java}, output)
    assert_match(/│\s+└── \e\[0;32mfile\.txt/, output)

    # test should be collapsed, and now includes the file
    assert_match(%r{└── \e\[1;34mtest/unit/java/com/company/\e\[0m\e\[0;32mTest\.java \(A\+\)\e\[0m}, output)
  end

  def test_collapse_with_single_file_in_directory
    # Create structure similar to test/node/test_node_class.rb
    FileUtils.mkdir_p('test/node')
    File.write('test/node/test_node_class.rb', 'class TestNodeClass; end')
    system('git add .')

    output = `#{File.join(__dir__, '../../bin/git-status-tree')} --collapse`
    # Should show root node
    assert_match(/^\e\[1;34m\.\e\[0m$/, output)
    # The entire path including the file should be collapsed
    assert_match(%r{└── \e\[1;34mtest/node/\e\[0m\e\[0;32mtest_node_class\.rb \(A\+\)\e\[0m}, output)
  end
end
