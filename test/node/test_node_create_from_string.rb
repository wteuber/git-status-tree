# frozen_string_literal: true

require_relative '../test_helper'

class TestNodeCreateFromString < Test::Unit::TestCase
  def test_create_from_string_argument_error
    assert_raise(ArgumentError) { Node.create_from_string }
  end

  def test_create_from_string_node_type_error_on_nil
    assert_raise(NodeTypeError) { Node.create_from_string(nil) }
  end

  def test_create_from_string_node_type_error_on_array
    assert_raise(NodeTypeError) { Node.create_from_string([]) }
  end

  def test_create_from_string_node_type_error_on_hash
    assert_raise(NodeTypeError) { Node.create_from_string({}) }
  end

  def test_create_from_string_node_name_error_on_empty_string
    assert_raise(NodeNameError) { Node.create_from_string('') }
  end

  def test_create_from_string
    assert_nothing_raised(NodeNameError) { Node.create_from_string('test') }
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
    node = Node.create_from_string('   path/to/ok.txt')
    assert_equal('.', node.name)
  end

  def test_create_from_string_children
    node = Node.create_from_string('   path/to/ok.txt')
    assert_equal([{ 'path' => [{ 'to' => ['ok.txt'] }] }], node.children.to_primitive)
  end

  def test_node_from_gs_empty_filename
    setup_node_tracking_for_empty_filename
    Node.send(:node_from_gs, 'M  ') # Empty filename results in empty ary_nodes after shift
    assert(@else_hit, 'Should have hit the else branch in node_from_gs')
  ensure
    restore_node_methods
  end

  def test_create_from_string__file_deleted
    node = Node.create_from_string(' D file_name')
    assert_equal '.', node.name
    assert_equal NodesCollection, node.children.class
    assert_equal 'file_name', node.children.nodes.first.name
    assert_equal nil, node.children.nodes.first.children
    assert_equal 'D', node.children.nodes.first.status
  end

  def test_create_from_string__file_renamed_same_directory
    node = Node.create_from_string('R  path/to/old_file.rb -> path/to/new_file.rb')
    assert_equal '.', node.name
    assert_equal NodesCollection, node.children.class

    path_node = node.children.nodes.first
    assert_equal 'path', path_node.name

    to_node = path_node.children.nodes.first
    assert_equal 'to', to_node.name

    rename_node = to_node.children.nodes.first
    assert_equal 'old_file.rb -> new_file.rb', rename_node.name
    assert_nil rename_node.children
    assert_equal 'R+', rename_node.status
  end

  def test_create_from_string__file_renamed_root_directory
    node = Node.create_from_string('R  old_file.rb -> new_file.rb')
    assert_equal 'old_file.rb -> new_file.rb', node.name
    assert_nil node.children
    assert_equal 'R+', node.status
  end

  def test_create_from_string__file_renamed_cross_directory
    node = Node.create_from_string('R  path/to/file.rb -> other/path/file.rb')
    assert_equal '.', node.name
    assert_equal NodesCollection, node.children.class

    path_node = node.children.nodes.first
    assert_equal 'path', path_node.name

    to_node = path_node.children.nodes.first
    assert_equal 'to', to_node.name

    rename_node = to_node.children.nodes.first
    assert_equal 'file.rb -> other/path/file.rb', rename_node.name
    assert_nil rename_node.children
    assert_equal 'R+', rename_node.status
  end

  def test_create_from_string__file_renamed_single_level_directory
    node = Node.create_from_string('R  dir/old_file.rb -> dir/new_file.rb')
    assert_equal '.', node.name
    assert_equal NodesCollection, node.children.class

    dir_node = node.children.nodes.first
    assert_equal 'dir', dir_node.name

    rename_node = dir_node.children.nodes.first
    assert_equal 'old_file.rb -> new_file.rb', rename_node.name
    assert_nil rename_node.children
    assert_equal 'R+', rename_node.status
  end

  private

  def setup_node_tracking_for_empty_filename
    Node.singleton_class.send(:public, :node_from_gs)
    @original_new = Node.method(:new)
    test_case = self
    Node.define_singleton_method(:new) do |name, children = nil, status = nil|
      test_case.instance_variable_set(:@else_hit, true) if children.nil? && !status.nil?
      test_case.instance_variable_get(:@original_new).call(name, children, status)
    end
  end

  def restore_node_methods
    Node.singleton_class.send(:remove_method, :new) if Node.singleton_class.respond_to?(:new)
    Node.singleton_class.send(:private, :node_from_gs)
  end
end
