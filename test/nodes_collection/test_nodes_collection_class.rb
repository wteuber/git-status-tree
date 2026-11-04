# frozen_string_literal: true

require_relative '../test_helper'

class TestNodesCollectionClass < Minitest::Test
  def test_defined?
    assert_equal('constant', defined?(NodesCollection))
  end

  def test_class?
    assert_kind_of(Class, NodesCollection)
  end

  def test_type_error_on_nil
    assert_raise(NodesCollectionTypeError) { NodesCollection.new(nil) }
  end

  def test_initialize_no_error
    assert_nothing_raised { NodesCollection.new }
  end

  def test_initialize
    assert_kind_of(NodesCollection, NodesCollection.new)
  end
end
