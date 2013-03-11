# encoding: utf-8

class TestNodeNameError < Test::Unit::TestCase
  def test_no_node_name_error
    assert_nothing_raised(NodeNameError){Node.new('valid')}
  end

  def test_node_name_error_on_nil
    assert_raise(NodeNameError){Node.new(nil)}
  end

  def test_node_name_error_on_array
    assert_raise(NodeNameError){Node.new([])}
  end

  def test_node_name_error_on_hash
    assert_raise(NodeNameError){Node.new({})}
  end
end
