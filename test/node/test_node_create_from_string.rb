# encoding: utf-8

class TestNodeCreateFromString < Test::Unit::TestCase

  def test_create_from_string_argument_error
    assert_raise(ArgumentError){Node.create_from_string}
  end

  def test_create_from_string_node_type_error_on_nil
    assert_raise(NodeTypeError){Node.create_from_string(nil)}
  end

  def test_create_from_string_node_type_error_on_array
    assert_raise(NodeTypeError){Node.create_from_string([])}
  end

  def test_create_from_string_node_type_error_on_hash
    assert_raise(NodeTypeError){Node.create_from_string({})}
  end

  def test_create_from_string_node_name_error_on_empty_string
    assert_raise(NodeNameError){Node.create_from_string('')}
  end

  def test_create_from_string
    assert_nothing_raised(NodeNameError){Node.create_from_string('test')}
  end

  def test_create_from_string_class
    assert(Node.create_from_string('   test').is_a?(Node))
  end

  def test_create_from_string_file?
    assert(Node.create_from_string('   test').children.nodes.first.file?)
  end

  def test_create_from_string_valid_file?
    assert(Node.create_from_string('   test').valid?)
  end

  def test_create_from_string_dir?
    assert(Node.create_from_string('   te/st').dir?)
  end

  def test_create_from_string_valid_dir?
    assert(Node.create_from_string('   te/st').valid?)
  end

  def test_create_from_string_name
    node = Node.create_from_string("   path/to/ok.txt")
    assert_equal('.', node.name)
  end

  def test_create_from_string_children
    node = Node.create_from_string('   path/to/ok.txt')
    assert_equal([{'path'=>[{'to'=>['ok.txt']}]}], node.children.to_primitive)
  end
end
