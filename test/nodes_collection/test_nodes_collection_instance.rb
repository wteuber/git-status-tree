# frozen_string_literal: true

require_relative '../test_helper'

class TestNodesCollectionInstance < Test::Unit::TestCase
  def test_new?
    assert(NodesCollection.respond_to?(:new))
  end

  def test_initialize_no_error
    assert_nothing_raised { NodesCollection.new }
  end

  def test_initialize
    assert(NodesCollection.new.is_a?(NodesCollection))
  end

  def test_add_file_empty
    a = NodesCollection.create_from_string('x')
    b = NodesCollection.new
    assert_equal(['x'], (a + b).to_primitive)
  end

  def test_add_empty_file
    a = NodesCollection.new
    b = NodesCollection.create_from_string('x')
    assert_equal(['x'], (a + b).to_primitive)
  end

  def test_add_equal_files
    a = NodesCollection.create_from_string('x')
    b = NodesCollection.create_from_string('x')
    assert_equal(['x'], (a + b).to_primitive)
  end

  def test_add_different_files
    a = NodesCollection.create_from_string 'x'
    b = NodesCollection.create_from_string 'y'
    assert_equal(%w[x y], (a + b).to_primitive)
  end

  def test_add_different_files_inverse
    a = NodesCollection.create_from_string 'y'
    b = NodesCollection.create_from_string 'x'
    assert_equal(%w[x y], (a + b).to_primitive)
  end

  def test_add_file_and_dir
    a = NodesCollection.create_from_string 'x'
    b = NodesCollection.create_from_string 'y/z'
    assert_equal([{ 'y' => ['z'] }, 'x'], (a + b).to_primitive)
  end

  def test_add_dir_and_file
    a = NodesCollection.create_from_string 'y/z'
    b = NodesCollection.create_from_string 'x'
    assert_equal([{ 'y' => ['z'] }, 'x'], (a + b).to_primitive)
  end

  def test_spaceship_operator
    node1 = Node.new('a.txt')
    node2 = Node.new('b.txt')
    collection1 = NodesCollection.new([node1])
    collection2 = NodesCollection.new([node2])
    collection1_dup = NodesCollection.new([node1])

    assert_equal(-1, collection1 <=> collection2)
    assert_equal(1, collection2 <=> collection1)
    assert_equal(0, collection1 <=> collection1_dup)
  end

  def test_valid_method
    node = Node.new('file.txt')
    collection = NodesCollection.new([node])
    assert(collection.valid?)

    empty_collection = NodesCollection.new([])
    assert(empty_collection.valid?)
  end

  def test_add_node_method
    # This method appears to be empty/not implemented
    collection = NodesCollection.new
    result = collection.add_node(Node.new('test.txt'))
    assert_nil(result)
  end

  def test_to_tree_s_with_depth
    node1 = Node.new('file1.txt', nil, 'M ')
    node2 = Node.new('file2.txt', nil, 'A ')
    collection = NodesCollection.new([node1, node2])

    output = collection.to_tree_s(1, [])
    assert_match(/file1\.txt/, output)
    assert_match(/file2\.txt/, output)
  end

  def test_nodes_collection_addition
    collection1 = NodesCollection.new([Node.new('file1.txt')])
    collection2 = NodesCollection.new([Node.new('file2.txt')])

    result = collection1 + collection2

    assert_instance_of(NodesCollection, result)
    assert_equal(2, result.nodes.length)
  end

  def test_complex_merge
    collection1 = create_mixed_collection('src', 'readme.txt')
    collection2 = create_mixed_collection('lib', 'test.txt')

    result = collection1 + collection2

    assert_equal(4, result.nodes.length)
    assert_equal(2, result.dirs.length)
    assert_equal(2, result.files.length)
  end

  def test_merge_with_common_nodes
    node1a = Node.new('common.rb', nil, 'M ')
    node1b = Node.new('unique1.rb', nil, 'A ')
    collection1 = NodesCollection.new([node1a, node1b])

    node2a = Node.new('common.rb', nil, 'D ')
    node2b = Node.new('unique2.rb', nil, '? ')
    collection2 = NodesCollection.new([node2a, node2b])

    result = collection1 + collection2

    assert_equal(3, result.nodes.length)
    names = result.nodes.map(&:name).sort
    assert_equal(['common.rb', 'unique1.rb', 'unique2.rb'], names)
  end

  def test_nodes_collection_case_in_merge
    coll1 = NodesCollection.new([Node.new('x.rb')])
    coll2 = NodesCollection.new([Node.new('y.rb')])

    merged = coll1.merge_nodes_with(coll2)

    assert_instance_of(Array, merged)
    assert_equal(2, merged.length)
    assert(merged.all? { |item| item.is_a?(Node) })
  end

  def test_merge_nodes_with_collection_case
    collection1 = NodesCollection.new([Node.new('a.txt')])
    collection2 = NodesCollection.new([Node.new('b.txt')])

    merged = collection1.merge_nodes_with(collection2)
    assert_equal(2, merged.length)

    result = collection1 + collection2
    assert_equal(2, result.nodes.length)
  end

  def test_merge_nodes_with_nodes_collection
    collection1 = NodesCollection.new([Node.new('file1.rb')])
    collection2 = NodesCollection.new([Node.new('file2.rb')])

    result = collection1.merge_nodes_with(collection2)

    assert_instance_of(Array, result)
    assert_equal(2, result.length)
    assert_equal(['file1.rb', 'file2.rb'], result.map(&:name).sort)
  end

  def test_merge_via_plus_operator
    c1 = NodesCollection.new([Node.new('a.txt')])
    c2 = NodesCollection.new([Node.new('b.txt')])

    result = c1 + c2

    assert_instance_of(NodesCollection, result)
    assert_equal(2, result.nodes.length)
  end

  def test_plus_operator_with_collection
    node1 = Node.new('file1.txt')
    node2 = Node.new('file2.txt')
    collection1 = NodesCollection.new([node1])
    collection2 = NodesCollection.new([node2])

    result_collection = collection1 + collection2
    assert_equal(2, result_collection.nodes.length)
    assert_equal('file1.txt', result_collection.nodes[0].name)
    assert_equal('file2.txt', result_collection.nodes[1].name)
  end

  def test_files_method
    file1 = Node.new('file1.txt')
    file2 = Node.new('file2.txt')
    dir1 = Node.new('dir1', NodesCollection.new([]))
    collection = NodesCollection.new([file1, dir1, file2])

    files = collection.files
    assert_equal(2, files.length)
    assert(files.all?(&:file?))
  end

  def test_dirs_method
    file1 = Node.new('file1.txt')
    dir1 = Node.new('dir1', NodesCollection.new([]))
    dir2 = Node.new('dir2', NodesCollection.new([]))
    collection = NodesCollection.new([file1, dir1, dir2])

    dirs = collection.dirs
    assert_equal(2, dirs.length)
    assert(dirs.all?(&:dir?))
  end

  def test_merge_nodes_with_node_same_name
    file1 = Node.new('same.txt', nil, 'M+')
    file2 = Node.new('different.txt')
    collection = NodesCollection.new([file1, file2])

    file3 = Node.new('same.txt', nil, 'A+')

    result = collection.merge_nodes_with_node(file3)
    assert_equal(3, result.length) # Should have merged node + different.txt + merged same.txt

    merged = result.find { |n| n.name == 'same.txt' }
    assert_not_nil(merged)
  end

  def test_merge_nodes_with_node_different_name
    file1 = Node.new('file1.txt')
    collection = NodesCollection.new([file1])

    file2 = Node.new('file2.txt')
    result = collection.merge_nodes_with_node(file2)

    assert_equal(2, result.length)
    assert_equal('file1.txt', result[0].name)
    assert_equal('file2.txt', result[1].name)
  end

  private

  def create_mixed_collection(dir_name, file_name)
    file = Node.new(file_name, nil, 'M ')
    dir = Node.new(dir_name, NodesCollection.new([Node.new('file.rb')]))
    NodesCollection.new([file, dir])
  end
end
