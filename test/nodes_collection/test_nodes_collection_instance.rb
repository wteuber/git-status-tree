# encoding: utf-8

class TestNodesCollectionInstance < Test::Unit::TestCase

  def test_new?
    assert(NodesCollection.respond_to?(:new))
  end

  def test_initialize_no_error
    assert_nothing_raised(){NodesCollection.new}
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
    assert_equal(['x', 'y'], (a + b).to_primitive)
  end

  def test_add_different_files_inverse
    a = NodesCollection.create_from_string 'y'
    b = NodesCollection.create_from_string 'x'
    assert_equal(['x', 'y'], (a + b).to_primitive)
  end

  def test_add_file_and_dir
    a = NodesCollection.create_from_string 'x'
    b = NodesCollection.create_from_string 'y/z'
    assert_equal([{'y' => ['z']}, 'x'], (a + b).to_primitive)
  end

  def test_add_dir_and_file
    a = NodesCollection.create_from_string 'y/z'
    b = NodesCollection.create_from_string 'x'
    assert_equal([{'y'=>['z']}, 'x'], (a + b).to_primitive)
  end

end
