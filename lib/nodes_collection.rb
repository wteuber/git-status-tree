# frozen_string_literal: true

# error class for invalid NodeCollection types
class NodesCollectionTypeError < StandardError
end

# collection of nodes
class NodesCollection # rubocop:disable Metrics/ClassLength
  attr_accessor :nodes

  def self.create_from_string(str_nodes, status = '   ')
    msg = '"str_nodes" must be String.'
    raise NodesCollectionTypeError, msg unless str_nodes.is_a? String

    ary_nodes = str_nodes.split(%r{/})
    create_from_valid_array(ary_nodes, status)
  end

  def self.create_from_array(ary_nodes, status)
    ary_nodes = [ary_nodes].flatten(1)

    msg = '"ary_nodes" must only contain Strings.'
    are_strings = ->(node) { node.is_a?(String) }
    raise NodesCollectionTypeError, msg unless ary_nodes.all?(&are_strings)

    create_from_valid_array(ary_nodes, status)
  end

  def self.new_from_nodes_array(all_nodes)
    raise msg unless all_nodes.all?(&Node.instances?)

    grouped_nodes = all_nodes.group_by(&:name)
    plain_nodes = plain_nodes(grouped_nodes)
    merged_nodes = merged_nodes(grouped_nodes)

    new(plain_nodes + merged_nodes)
  end

  def self.create_from_valid_array(ary_nodes, status)
    name = ary_nodes.shift
    node = if ary_nodes.any?
             children = create_from_valid_array(ary_nodes, status)
             Node.new(name, children)
           else
             Node.new(name, nil, status)
           end
    new([node])
  end

  private_class_method :create_from_valid_array

  def self.merged_nodes(grouped_nodes)
    merged_nodes = []
    grouped_nodes.each_value do |nodes|
      merged_nodes << (nodes[0] + nodes[1]).nodes[0] if nodes.length == 2
    end
    merged_nodes
  end
  private_class_method :merged_nodes

  def self.plain_nodes(grouped_nodes)
    grouped_nodes.filter { |_, nodes| nodes.length == 1 }.values.flatten(1)
  end
  private_class_method :plain_nodes

  def initialize(nodes = [])
    nodes = [nodes].flatten(1)

    msg = '"nodes" must only contain Nodes.'
    are_nodes = ->(node) { node.is_a?(Node) }
    raise NodesCollectionTypeError, msg unless nodes.all?(&are_nodes)

    @nodes = nodes
  end

  # @return [NodesCollection]
  def +(other)
    raise 'not a Node or NodesCollection' unless other.is_a?(Node) || other.is_a?(self.class)

    all_nodes = merge_nodes_with other

    dir_nodes = dir_nodes(all_nodes)
    file_nodes = file_nodes(all_nodes)

    self.class.new(dir_nodes + file_nodes)
  end

  # @return [Integer]
  def <=>(other)
    to_primitive <=> other.to_primitive
  end

  # @return [Array<Node>]
  def nodes_not_in(other)
    self_names = nodes.map(&:name)
    other_names = other.nodes.map(&:name)

    self_only_names = self_names - (self_names & other_names)

    nodes.select { |node| self_only_names.include?(node.name) }
  end

  # @return [Array<Node>]
  def merge_common_nodes_with(other)
    self_names = nodes.map(&:name)
    other_names = other.nodes.map(&:name)

    common_names = self_names & other_names
    all_nodes = nodes + other.nodes

    common_names.map do |name|
      all_nodes.select { |node| node.name == name }.reduce(&:+).nodes[0]
    end
  end

  # @return [Array<Node>]
  def merge_nodes_with(other)
    case other
    when Node
      nodes_merged = merge_nodes_with_node(other)
    when NodesCollection
      nodes_merged = merge_nodes_with_collection(other)
    end

    nodes_merged
  end

  def files
    nodes.select(&:file?)
  end

  def dirs
    nodes.select(&:dir?)
  end

  def sort!
    nodes.sort!
  end

  def to_primitive
    nodes.map(&:to_primitive)
  end

  def valid?
    nodes.is_a?(Array) &&
      nodes.all? { |node| node.is_a?(Node) } &&
      nodes&.all?(&:valid?)
    # TODO: compare uniqueness of file and dir names.
  end

  def to_tree_s(depth = 0, open_parents = [])
    tree_s = ''

    if nodes.length > 1
      to_tree_s = ->(node) { node.to_tree_s(depth, open_parents, last: false) }
      tree_s += nodes[0..-2].map(&to_tree_s) * ''
    end
    tree_s += nodes.last.to_tree_s(depth, open_parents)

    tree_s
  end

  def file_nodes(all_nodes)
    all_files = all_nodes.select(&:file?)
    files_collection = self.class.new all_files
    files_collection.sort!
  end

  def dir_nodes(all_nodes)
    all_dirs = all_nodes.select(&:dir?)
    dirs_collection = self.class.new_from_nodes_array all_dirs
    dirs_collection.sort!
  end

  def merge_nodes_with_collection(other)
    self_dedicated_nodes = nodes_not_in other
    other_dedicated_nodes = other.nodes_not_in self
    common_nodes = merge_common_nodes_with other

    self_dedicated_nodes + common_nodes + other_dedicated_nodes
  end

  def merge_nodes_with_node(other)
    if nodes.map(&:name).include?(other.name)
      equal_names = ->(node) { node.name == other.name }
      collection_merged = nodes.select(&equal_names)[0] + other
      other = collection_merged.nodes[0]
    end

    nodes + [other]
  end

  def add_node(other); end
end
