# encoding: utf-8

# error class for invalid NodeCollection types
class NodesCollectionTypeError < StandardError;
end

# collection of nodes
class NodesCollection
  attr_accessor :nodes

  def self.create_from_string(str_nodes, status = '   ')
    msg = '"str_nodes" must be String.'
    raise NodesCollectionTypeError, msg unless str_nodes.is_a? String

    ary_nodes = str_nodes.split(/\//)
    create_from_valid_array(ary_nodes, status)
  end

  def self.create_from_array(ary_nodes, status)
    ary_nodes = [ary_nodes].flatten(1)

    msg = '"ary_nodes" must only contain Strings.'
    are_strings = lambda { |node| node.is_a?(String) }
    raise NodesCollectionTypeError, msg unless ary_nodes.all? &are_strings

    create_from_valid_array(ary_nodes, status)
  end

  def self.new_from_nodes_array(nodes)
    raise msg unless nodes.all? &Node.instances?

    all_nodes = nodes.group_by(&:name)

    plain_nodes = []
    all_nodes.each { |_, nodes| plain_nodes << nodes if nodes.length == 1 }
    plain_nodes.flatten!(1)

    merged_nodes = []
    all_nodes.each do |_, nodes|
      if nodes.length == 2
        merged_nodes << (nodes[0] + nodes[1]).nodes[0]
      end
    end

    self.new(plain_nodes + merged_nodes)
  end

  def self.create_from_valid_array(ary_nodes, status)
    name = ary_nodes.shift
    node = if ary_nodes.any?
             children = create_from_valid_array(ary_nodes, status)
             Node.new(name, children)
           else
             Node.new(name, nil, status)
           end
    self.new([node])
  end

  private_class_method :create_from_valid_array

  def initialize(nodes = [])
    nodes = [nodes].flatten(1)

    msg = '"nodes" must only contain Nodes.'
    are_nodes = lambda { |node| node.is_a?(Node) }
    raise NodesCollectionTypeError, msg unless nodes.all? &are_nodes
    @nodes = nodes
  end

  # @return [NodesCollection]
  def +(other)
    unless other.is_a?(Node) || other.is_a?(self.class)
      raise 'not a Node or NodesCollection'
    end

    all_nodes = merge_nodes_with other
    all_dirs = all_nodes.select(&:dir?)
    all_files = all_nodes.select(&:file?)

    dirs_collection = self.class.new_from_nodes_array all_dirs
    files_collection = self.class.new all_files


    dir_nodes = dirs_collection.sort!
    file_nodes = files_collection.sort!

    self.class.new(dir_nodes + file_nodes)
  end

  # @return [Integer]
  def <=>(other)
    self.to_primitive <=> other.to_primitive
  end

  # @return [Array<Node>]
  def nodes_not_in(other)
    self_names = self.nodes.map(&:name)
    other_names = other.nodes.map(&:name)

    self_only_names = self_names - (self_names & other_names)

    self.nodes.select { |node| self_only_names.include?(node.name) }
  end

  # @return [Array<Node>]
  def merge_common_nodes_with(other)
    self_names = self.nodes.map(&:name)
    other_names = other.nodes.map(&:name)

    common_names = self_names & other_names
    all_nodes = self.nodes + other.nodes

    common_names.map do |name|
      all_nodes.select { |node| node.name == name }.reduce(&:+).nodes[0]
    end
  end

  # @return [Array<Node>]
  def merge_nodes_with(other)
    if other.is_a? Node
      if self.nodes.map(&:name).include?(other.name)
        equal_names = lambda { |node| node.name == other.name }
        collection_merged = self.nodes.select(&equal_names)[0] + other
        other = collection_merged.nodes[0]
      end

      nodes_merged = self.nodes + [other]
    elsif other.is_a? NodesCollection
      self_dedicated_nodes = self.nodes_not_in other
      other_dedicated_nodes = other.nodes_not_in self
      common_nodes = self.merge_common_nodes_with other

      nodes_merged = self_dedicated_nodes + common_nodes + other_dedicated_nodes
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
    nodes &&
        nodes.is_a?(Array) &&
        nodes.all? { |node| node.is_a?(Node) } &&
        nodes.all?(&:valid?)
    #TODO compare uniqueness of file and dir names.
  end

  def to_tree_s(depth = 0, open_parents = [])
    tree_s = ''

    if nodes.length > 1
      to_tree_s = lambda { |node| node.to_tree_s(depth, open_parents, false) }
      tree_s << nodes[0..-2].map(&to_tree_s) * ''
    end
    tree_s << nodes.last.to_tree_s(depth, open_parents)

    tree_s
  end

  private
  def add_node(other)
  end

end
