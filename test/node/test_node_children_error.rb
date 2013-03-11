# encoding: utf-8

class TestNodeChildrenError < Test::Unit::TestCase
  def test_no_node_children_error
    assert_nothing_raised(NodeChildrenError){Node.new('valid')}
  end

  def test_no_node_children_error_on_nodes_collection
    assert_nothing_raised(NodeChildrenError){Node.new('valid', NodesCollection.new)}
  end

  def test_node_children_error_on_array
    assert_raise(NodeChildrenError){Node.new('valid', [])}
  end

  def test_node_children_error_on_nil
    assert_nothing_raised(NodeChildrenError){Node.new('valid', nil)}
  end

  def test_no_node_children_error_on_string
    assert_raise(NodeChildrenError){Node.new('valid', '')}
  end

  def test_node_children_error_on_hash
    assert_raise(NodeChildrenError){Node.new('valid', {})}
  end
end
