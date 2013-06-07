# encoding: utf-8

class NodesCollectionTypeError < StandardError; end

class NodesCollection
  attr_accessor :nodes

  def self.create_from_string(str_nodes, status = '   ')
    raise NodesCollectionTypeError, '"str_nodes" must be String.' unless str_nodes.is_a? String
    ary_nodes = str_nodes.split(/\//)
    create_from_valid_array(ary_nodes, status)
  end

  def self.create_from_array(ary_nodes, status)
    ary_nodes = [ary_nodes].flatten(1)
    raise NodesCollectionTypeError, '"ary_nodes" must only contain Strings.' unless ary_nodes.all? { |node|  node.is_a?(String)}
    create_from_valid_array(ary_nodes, status)
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
    raise NodesCollectionTypeError, '"nodes" must only contain Nodes.' unless nodes.all? { |node|  node.is_a?(Node)}
    @nodes = nodes
  end

  # @return [NodesCollection]
  def +(other)
    raise 'not a Node or ' + self.class.to_s unless other.is_a?(Node) || other.is_a?(self.class)

    if other.is_a?(Node)
      if self.nodes.map(&:name).include?(other.name)
        merged_node = self.nodes.delete(self.nodes.select{|node| node.name == other.name}[0])
        merged_node += other
        self.nodes += merged_node
      else
        self.nodes = self.nodes + [other]
      end

      all_dirs = (self.dirs).group_by(&:name)
      files_collection = self.class.new(self.files)
    else # NodesCollection
      self_names = self.nodes.map(&:name)
      other_names = other.nodes.map(&:name)
      merge_names = self_names & other_names

      self_only_names = self_names - merge_names
      other_only_names = other_names - merge_names

      self_only_nodes = self.nodes.select{|node| self_only_names.include?(node.name)}
      other_only_nodes = other.nodes.select{|node| other_only_names.include?(node.name)}

      merge_nodes = merge_names.map do |name|
        (self.nodes + other.nodes).select{|node| node.name == name}.
          reduce(&:+).nodes[0]
      end

      all_nodes = self_only_nodes + merge_nodes + other_only_nodes

      all_dirs = all_nodes.select(&:dir?).group_by(&:name)
      files_collection = self.class.new(all_nodes.select(&:file?))
    end

    plain_dirs = Hash[all_dirs.select{|_,nodes| nodes.length == 1}].values.flatten(1) || []
    merge_dirs = Hash[all_dirs.select{|_,nodes| nodes.length == 2}].map{|name,nodes| (nodes[0] + nodes[1]).nodes[0]} || []
    dirs_collection = self.class.new(plain_dirs + merge_dirs)
    dir_nodes = dirs_collection.sort!

    file_nodes = files_collection.sort!

    self.class.new(dir_nodes + file_nodes)
  end

  def <=>(other)
    self.to_primitive <=> other.to_primitive
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
      nodes.all? { |node|  node.is_a?(Node)} &&
      nodes.all?(&:valid?)
    #TODO compare uniqueness of file and dir names.
  end

  def to_tree_s(depth = 0, open_parents = [])
    tree_s = ''

    if nodes.length > 1
      tree_s << nodes[0..-2].map{|node| node.to_tree_s(depth, open_parents, false)}*''
    end
    tree_s << nodes.last.to_tree_s(depth, open_parents)

    tree_s
  end
end
