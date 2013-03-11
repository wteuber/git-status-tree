# encoding: utf-8

class TestNodeClass < Test::Unit::TestCase
  def test_defined
    assert_equal("constant" , defined?(Node))
  end

  def test_class
    assert(Node.is_a?(Class))
  end

  def test_initialize_argument_error
    assert_raise(ArgumentError){Node.new}
  end

  def test_initialize_no_error
    assert_nothing_raised(){Node.new('test')}
  end

  def test_initialize
    assert(Node.new('test').is_a?(Node))
  end
end
