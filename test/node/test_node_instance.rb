# frozen_string_literal: true

require_relative '../test_helper'

class TestNodeInstance < Test::Unit::TestCase
  def test_file?
    assert(Node.new('test').file?)
  end

  def test_dir?
    assert(Node.new('test', NodesCollection.new).dir?)
  end

  def test_valid_file?
    assert(Node.new('test').valid?)
  end

  def test_valid_dir?
    assert(Node.new('test', NodesCollection.new).valid?)
  end

  def test_not_file?
    assert(!Node.new('test', NodesCollection.new).file?)
  end

  def test_not_dir?
    assert(!Node.new('test').dir?)
  end

  def test_not_valid?
    node = Node.new('test')
    node.children = ''
    assert(!node.valid?)
  end

  def test_invalid_node_returns_false
    # This tests valid? returning false when node has invalid state
    # Create a node with invalid state by manipulating its internals
    node = Node.new('test')
    # Force it to be neither file nor dir by setting children to an invalid value
    node.instance_variable_set(:@children, 'invalid')
    assert_equal(false, node.valid?)
  end

  def test_children_not_valid?
    node = Node.create_from_string('./one/two/three')
    node.children.nodes.first.children.nodes.first.name = ''
    assert(!node.valid?)
  end

  def test_simple_root_file
    node = Node.create_from_string('M  test.txt')
    assert_equal('.', node.name)
    assert_not_nil(node.children)
    assert_equal('test.txt', node.children.nodes[0].name)
  end

  def test_file_to_primitive
    assert_equal('test', Node.new('test').to_primitive)
  end

  def test_dir_to_primitive
    assert_equal({ 'test' => [] }, Node.new('test', NodesCollection.new).to_primitive)
  end

  def test_spaceship_operator_different_types
    file_node = Node.new('file.txt')
    dir_node = Node.new('dir', NodesCollection.new([]))

    assert_equal(-1, dir_node <=> file_node)
    assert_equal(1, file_node <=> dir_node)

    file1 = Node.new('same.txt')
    file2 = Node.new('same.txt')
    assert_equal(0, file1 <=> file2)
  end

  def test_spaceship_operator_different_names
    file_a = Node.new('a.txt')
    file_b = Node.new('b.txt')
    assert_equal(-1, file_a <=> file_b)
    assert_equal(1, file_b <=> file_a)

    dir_a = Node.new('a_dir', NodesCollection.new([]))
    dir_b = Node.new('b_dir', NodesCollection.new([]))
    assert_equal(-1, dir_a <=> dir_b)
    assert_equal(1, dir_b <=> dir_a)
  end

  def test_add_equal_files_class
    a = Node.create_from_string '   x'
    b = Node.create_from_string '   x'
    assert_equal(NodesCollection, (a + b).class)
  end

  def test_add_equal_files_structure
    a = Node.create_from_string '   x'
    b = Node.create_from_string '   x'
    assert_equal([{ '.' => ['x'] }], (a + b).to_primitive)
  end

  def test_add_different_files
    a = Node.create_from_string '   x'
    b = Node.create_from_string '   y'
    assert_equal([{ '.' => %w[x y] }], (a + b).to_primitive)
  end

  def test_add_different_files_sort
    a = Node.create_from_string '   x'
    b = Node.create_from_string '   y'
    assert_equal([{ '.' => %w[x y] }], (b + a).to_primitive)
  end

  def test_add_file_and_dir
    a = Node.create_from_string '   x'
    b = Node.create_from_string '   y/z'
    assert_equal([{ '.' => [{ 'y' => ['z'] }, 'x'] }], (a + b).to_primitive)
  end

  def test_add_dir_and_file
    a = Node.create_from_string '   y/z'
    b = Node.create_from_string '   x'
    assert_equal([{ '.' => [{ 'y' => ['z'] }, 'x'] }], (a + b).to_primitive)
  end

  def test_add_equal_dirs
    a = Node.create_from_string '   x/y'
    b = Node.create_from_string '   x/y'
    assert_equal([{ '.' => [{ 'x' => ['y'] }] }], (b + a).to_primitive)
  end

  def test_plain_file_to_tree_s
    a = Node.create_from_string '   x'
    assert_equal(<<~EXPECTED, a.to_tree_s)
      \e[1;34m.\e[0m
      └── \e[0;32mx ( +)\e[0m
    EXPECTED
  end

  def test_dir_with_child_to_tree_s
    a = Node.create_from_string '   x/y'
    assert_equal(<<~EXPECTED, a.to_tree_s)
      \e[1;34m.\e[0m
      └── \e[1;34mx\e[0m
          └── \e[0;32my ( +)\e[0m
    EXPECTED
  end

  def test_dir_with_children_to_tree_s
    a = Node.create_from_string '   ./x'
    b = Node.create_from_string '   ./y'

    node = (a + b).nodes.first

    assert_equal(<<~EXPECTED, node.to_tree_s)
      \e[1;34m.\e[0m
      └── \e[1;34m.\e[0m
          ├── \e[0;32mx ( +)\e[0m
          └── \e[0;32my ( +)\e[0m
    EXPECTED
  end

  def test_dir_with_children_and_file_to_tree_s
    a = Node.create_from_string '   ./x/y'
    b = Node.create_from_string '   ./z'

    node = (a + b).nodes.first

    assert_equal(<<~EXPECTED, node.to_tree_s)
      \e[1;34m.\e[0m
      └── \e[1;34m.\e[0m
          ├── \e[1;34mx\e[0m
          │   └── \e[0;32my ( +)\e[0m
          └── \e[0;32mz ( +)\e[0m
    EXPECTED
  end

  def test_status_untracked
    a = Node.create_from_string '?? x'
    assert_equal(<<~EXPECTED, a.to_tree_s)
      \e[1;34m.\e[0m
      └── \e[0;31mx (?)\e[0m
    EXPECTED
  end

  def test_status_added_unstaged
    a = Node.create_from_string ' A x'
    assert_equal(<<~EXPECTED, a.to_tree_s)
      \e[1;34m.\e[0m
      └── \e[0;31mx (A)\e[0m
    EXPECTED
  end

  def test_status_added_staged
    a = Node.create_from_string 'A  x'
    assert_equal("\e[1;34m.\e[0m\n└── \e[0;32mx (A+)\e[0m\n", a.to_tree_s)
  end

  def test_status_modified_unstaged
    a = Node.create_from_string ' M x'
    assert_equal(<<~EXPECTED, a.to_tree_s)
      \e[1;34m.\e[0m
      └── \e[0;31mx (M)\e[0m
    EXPECTED
  end

  def test_status_modified_staged
    a = Node.create_from_string 'M  x'
    assert_equal(<<~EXPECTED, a.to_tree_s)
      \e[1;34m.\e[0m
      └── \e[0;32mx (M+)\e[0m
    EXPECTED
  end

  def test_status_deleted_unstaged
    a = Node.create_from_string ' D x'
    assert_equal(<<~EXPECTED, a.to_tree_s)
      \e[1;34m.\e[0m
      └── \e[0;31mx (D)\e[0m
    EXPECTED
  end

  def test_status_deleted_staged
    a = Node.create_from_string 'D  x'
    assert_equal(<<~EXPECTED, a.to_tree_s)
      \e[1;34m.\e[0m
      └── \e[0;32mx (D+)\e[0m
    EXPECTED
  end
end
