# encoding: utf-8

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

  def test_children_not_valid?
    node = Node.create_from_string('./one/two/three')
    node.children.nodes.first.children.nodes.first.name = ''
    assert(!node.valid?)
  end

  def test_file_to_primitive
    assert_equal('test', Node.new('test').to_primitive)
  end

  def test_dir_to_primitive
    assert_equal({'test' => []}, Node.new('test', NodesCollection.new).to_primitive)
  end

  def test_add_equal_files
    a = Node.create_from_string '   x'
    b = Node.create_from_string '   x'
    assert_equal(NodesCollection, (a + b).class)
  end

  def test_add_equal_files
    a = Node.create_from_string '   x'
    b = Node.create_from_string '   x'
    assert_equal([{"."=>["x"]}], (a + b).to_primitive)
  end

  def test_add_different_files
    a = Node.create_from_string '   x'
    b = Node.create_from_string '   y'
    assert_equal([{"."=>["x", "y"]}], (a + b).to_primitive)
  end

  def test_add_different_files_sort
    a = Node.create_from_string '   x'
    b = Node.create_from_string '   y'
    assert_equal([{"."=>["x", "y"]}], (b + a).to_primitive)
  end

  def test_add_file_and_dir
    a = Node.create_from_string '   x'
    b = Node.create_from_string '   y/z'
    assert_equal([{"."=>[{"y"=>["z"]}, "x"]}], (a + b).to_primitive)
  end

  def test_add_dir_and_file
    a = Node.create_from_string '   y/z'
    b = Node.create_from_string '   x'
    assert_equal([{"."=>[{"y"=>["z"]}, "x"]}], (a + b).to_primitive)
  end

  def test_add_equal_dirs
    a = Node.create_from_string '   x/y'
    b = Node.create_from_string '   x/y'
    assert_equal([{"."=>[{"x"=>["y"]}]}], (b + a).to_primitive)
  end

  def test_plain_file_to_tree_s
    a = Node.create_from_string '   x'
    assert_equal("\e[1;34m.\e[0m\n└── x ()\e[0m\n", a.to_tree_s)
  end

  def test_dir_with_child_to_tree_s
    a = Node.create_from_string '   x/y'
    assert_equal("\e[1;34m.\e[0m\n└── \e[1;34mx\e[0m\n    └── y ()\e[0m\n", a.to_tree_s)
  end

  def test_dir_with_children_to_tree_s
    a = Node.create_from_string '   ./x'
    b = Node.create_from_string '   ./y'
    node = (a + b).nodes.first
    assert_equal("\e[1;34m.\e[0m\n└── \e[1;34m.\e[0m\n    ├── x ()\e[0m\n    └── y ()\e[0m\n", node.to_tree_s)
  end

  def test_dir_with_children_and_file_to_tree_s
    a = Node.create_from_string '   ./x/y'
    b = Node.create_from_string '   ./z'
    node = (a + b).nodes.first
    assert_equal("\e[1;34m.\e[0m\n└── \e[1;34m.\e[0m\n    ├── \e[1;34mx\e[0m\n    │   └── y ()\e[0m\n    └── z ()\e[0m\n", node.to_tree_s)
  end
end
