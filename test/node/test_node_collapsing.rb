# frozen_string_literal: true

require_relative '../test_helper'

class TestNodeCollapsing < Test::Unit::TestCase
  def setup
    Node.indent = 4
    Node.collapse_dirs = false
  end

  def teardown
    Node.collapse_dirs = false
  end

  def test_collapsible_returns_false_for_file
    file = Node.new('file.txt', nil, 'M')
    refute file.collapsible?
  end

  def test_collapsible_returns_false_for_dir_with_no_children
    dir = Node.new('dir', NodesCollection.new([]))
    refute dir.collapsible?
  end

  def test_collapsible_returns_false_for_dir_with_multiple_children
    child1 = Node.new('child1')
    child2 = Node.new('child2')
    dir = Node.new('dir', NodesCollection.new([child1, child2]))
    refute dir.collapsible?
  end

  def test_collapsible_returns_true_for_dir_with_single_file_child
    file = Node.new('file.txt', nil, 'M')
    dir = Node.new('dir', NodesCollection.new([file]))
    assert dir.collapsible?
  end

  def test_collapsible_returns_true_for_dir_with_single_dir_child
    child_dir = Node.new('child', NodesCollection.new([]))
    parent_dir = Node.new('parent', NodesCollection.new([child_dir]))
    assert parent_dir.collapsible?
  end

  def test_collapsed_path_returns_name_for_non_collapsible
    file = Node.new('file.txt', nil, 'M')
    assert_equal 'file.txt', file.collapsed_path
  end

  def test_collapsed_path_includes_file_for_dir_with_single_file
    # Create structure: a/b/file.txt
    file = Node.new('file.txt', nil, 'M')
    b_dir = Node.new('b', NodesCollection.new([file]))
    a_dir = Node.new('a', NodesCollection.new([b_dir]))

    assert_equal 'a/b/file.txt', a_dir.collapsed_path
  end

  def test_collapsed_path_returns_full_path_for_collapsible_dirs
    # Create deeply nested structure: a/b/c/file.txt
    file = Node.new('file.txt', nil, 'M')
    c_dir = Node.new('c', NodesCollection.new([file]))
    b_dir = Node.new('b', NodesCollection.new([c_dir]))
    a_dir = Node.new('a', NodesCollection.new([b_dir]))

    assert_equal 'a/b/c/file.txt', a_dir.collapsed_path
  end

  def test_deepest_collapsible_node_returns_self_for_non_collapsible
    file = Node.new('file.txt', nil, 'M')
    assert_equal file, file.deepest_collapsible_node
  end

  def test_deepest_collapsible_node_with_file_at_end
    # Create structure: a/b/file.txt
    file = Node.new('file.txt', nil, 'M')
    b_dir = Node.new('b', NodesCollection.new([file]))
    a_dir = Node.new('a', NodesCollection.new([b_dir]))

    assert_equal b_dir, a_dir.deepest_collapsible_node
  end

  def test_deepest_collapsible_node_returns_deepest_dir
    # Create deeply nested structure: a/b/c/file.txt
    file = Node.new('file.txt', nil, 'M')
    c_dir = Node.new('c', NodesCollection.new([file]))
    b_dir = Node.new('b', NodesCollection.new([c_dir]))
    a_dir = Node.new('a', NodesCollection.new([b_dir]))

    assert_equal c_dir, a_dir.deepest_collapsible_node
  end

  def test_collapsed_with_file_returns_true_when_ending_with_file
    file = Node.new('file.txt', nil, 'M')
    dir = Node.new('dir', NodesCollection.new([file]))
    assert dir.collapsed_with_file?
  end

  def test_collapsed_with_file_returns_false_when_ending_with_dir
    child_dir = Node.new('child', NodesCollection.new([]))
    parent_dir = Node.new('parent', NodesCollection.new([child_dir]))
    refute parent_dir.collapsed_with_file?
  end

  def test_tree_output_without_collapse
    # Create structure: a/b/c/file.txt
    file = Node.new('file.txt', nil, 'M')
    c_dir = Node.new('c', NodesCollection.new([file]))
    b_dir = Node.new('b', NodesCollection.new([c_dir]))
    a_dir = Node.new('a', NodesCollection.new([b_dir]))
    root = Node.new('.', NodesCollection.new([a_dir]))

    Node.collapse_dirs = false
    expected = <<~EXPECTED
      \e[1;34m.\e[0m
      └── \e[1;34ma\e[0m
          └── \e[1;34mb\e[0m
              └── \e[1;34mc\e[0m
                  └── \e[0;31mfile.txt (M)\e[0m
    EXPECTED

    assert_equal expected, root.to_tree_s
  end

  def test_tree_output_with_collapse_ending_in_file
    # Create structure: a/b/c/file.txt
    file = Node.new('file.txt', nil, 'M')
    c_dir = Node.new('c', NodesCollection.new([file]))
    b_dir = Node.new('b', NodesCollection.new([c_dir]))
    a_dir = Node.new('a', NodesCollection.new([b_dir]))
    root = Node.new('.', NodesCollection.new([a_dir]))

    Node.collapse_dirs = true
    expected = <<~EXPECTED
      \e[1;34m.\e[0m
      └── \e[1;34ma/b/c/\e[0m\e[0;31mfile.txt (M)\e[0m
    EXPECTED

    assert_equal expected, root.to_tree_s
  end

  def test_tree_output_with_collapse_ending_in_empty_dir
    # Create structure: a/b/c/ (empty directory)
    c_dir = Node.new('c', NodesCollection.new([]))
    b_dir = Node.new('b', NodesCollection.new([c_dir]))
    a_dir = Node.new('a', NodesCollection.new([b_dir]))
    root = Node.new('.', NodesCollection.new([a_dir]))

    Node.collapse_dirs = true
    expected = <<~EXPECTED
      \e[1;34m.\e[0m
      └── \e[1;34ma/b/c\e[0m
    EXPECTED

    assert_equal expected, root.to_tree_s
  end

  def test_tree_output_with_collapse_single_file_in_dir
    # Create structure: test/node/test_node_class.rb
    file = Node.new('test_node_class.rb', nil, 'R+')
    node_dir = Node.new('node', NodesCollection.new([file]))
    test_dir = Node.new('test', NodesCollection.new([node_dir]))
    root = Node.new('.', NodesCollection.new([test_dir]))

    Node.collapse_dirs = true
    expected = <<~EXPECTED
      \e[1;34m.\e[0m
      └── \e[1;34mtest/node/\e[0m\e[0;32mtest_node_class.rb (R+)\e[0m
    EXPECTED

    assert_equal expected, root.to_tree_s
  end

  def test_tree_output_with_collapse_and_branching
    # Create structure:
    # a/b/module
    #   ├── module-api/src/main/java/file1.java
    #   └── module-impl/src/main/java/file2.java

    file1 = Node.new('file1.java', nil, 'A+')
    java1 = Node.new('java', NodesCollection.new([file1]))
    main1 = Node.new('main', NodesCollection.new([java1]))
    src1 = Node.new('src', NodesCollection.new([main1]))
    api = Node.new('module-api', NodesCollection.new([src1]))

    file2 = Node.new('file2.java', nil, 'M')
    java2 = Node.new('java', NodesCollection.new([file2]))
    main2 = Node.new('main', NodesCollection.new([java2]))
    src2 = Node.new('src', NodesCollection.new([main2]))
    impl = Node.new('module-impl', NodesCollection.new([src2]))

    module_dir = Node.new('module', NodesCollection.new([api, impl]))
    b_dir = Node.new('b', NodesCollection.new([module_dir]))
    a_dir = Node.new('a', NodesCollection.new([b_dir]))
    root = Node.new('.', NodesCollection.new([a_dir]))

    Node.collapse_dirs = true
    expected = <<~EXPECTED
      \e[1;34m.\e[0m
      └── \e[1;34ma/b/module\e[0m
          ├── \e[1;34mmodule-api/src/main/java/\e[0m\e[0;32mfile1.java (A+)\e[0m
          └── \e[1;34mmodule-impl/src/main/java/\e[0m\e[0;31mfile2.java (M)\e[0m
    EXPECTED

    assert_equal expected, root.to_tree_s
  end

  def test_tree_output_with_mixed_files_and_dirs
    # Create structure where collapsing stops at directory with files
    # a/b/
    #   ├── file.txt
    #   └── c/d/file2.txt

    file1 = Node.new('file.txt', nil, 'M')
    file2 = Node.new('file2.txt', nil, 'A+')
    d_dir = Node.new('d', NodesCollection.new([file2]))
    c_dir = Node.new('c', NodesCollection.new([d_dir]))
    b_dir = Node.new('b', NodesCollection.new([c_dir, file1]))
    a_dir = Node.new('a', NodesCollection.new([b_dir]))
    root = Node.new('.', NodesCollection.new([a_dir]))

    Node.collapse_dirs = true
    expected = <<~EXPECTED
      \e[1;34m.\e[0m
      └── \e[1;34ma/b\e[0m
          ├── \e[1;34mc/d/\e[0m\e[0;32mfile2.txt (A+)\e[0m
          └── \e[0;31mfile.txt (M)\e[0m
    EXPECTED

    assert_equal expected, root.to_tree_s
  end

  def test_color_collapsed_file_with_no_directory_separator
    # Create a node to access the private method
    file = Node.new('file.txt', nil, 'M')
    dir = Node.new('dir', NodesCollection.new([file]))

    # Directly test the color_collapsed_file method with a path that has no "/"
    # This simulates a collapsed path that is just a filename
    result = dir.send(:color_collapsed_file, 'singlefile.txt', 'M')

    # When there's no directory in the path, it should just color the file
    expected = "\e[0;31msinglefile.txt (M)\e[0m"
    assert_equal expected, result
  end
end
