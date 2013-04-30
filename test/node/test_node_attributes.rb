# encoding: utf-8

class TestNodeAttributes < Test::Unit::TestCase

  def test_node_name_file
    assert_equal('file.txt', Node.new('file.txt').name)
  end

  def test_node_name_dir
    assert_equal('dir_name', Node.new('dir_name', NodesCollection.new).name)
  end

  def test_node_children_file
    assert_nil(Node.new('file.txt').children)
  end

  def test_node_children_dir
    collection = NodesCollection.new([])
    assert_equal(collection, Node.new('dir_name', collection).children)
  end
end
