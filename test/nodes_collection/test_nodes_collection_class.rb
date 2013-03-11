# encoding: utf-8

class TestNodesCollectionClass < Test::Unit::TestCase
  def test_defined
    assert_equal("constant" , defined?(NodesCollection))
  end

  def test_class
    assert(NodesCollection.is_a?(Class))
  end

  def test_argument_error
    assert_raise(NodesCollectionTypeError){NodesCollection.new(nil)}
  end

  def test_initialize_no_error
    assert_nothing_raised(){NodesCollection.new}
  end

  def test_initialize
    assert(NodesCollection.new.is_a?(NodesCollection))
  end
end
