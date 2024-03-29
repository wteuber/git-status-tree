# frozen_string_literal: true

class NodeNameError < StandardError; end
class NodeChildrenError < StandardError; end
class NodeTypeError < StandardError; end

# A Node represents a file or directory in the git-status-tree
class Node # rubocop:disable Metrics/ClassLength
  class << self
    attr_accessor :indent
  end

  attr_accessor :status, :name, :children

  def initialize(name, children = nil, status = nil)
    self.class.indent ||= 4
    validate_name!(name)

    msg = '"children" must be a NodesCollection or nil.'
    valid_nodes_collection = children.nil? || children.is_a?(NodesCollection)
    raise NodeChildrenError, msg unless valid_nodes_collection

    @name = name
    @children = children
    @status = status || '??'
  end

  def self.create_from_string(gs_porcelain)
    msg = '"str_node" must be String.'
    raise NodeTypeError, msg unless gs_porcelain.is_a? String
    raise NodeNameError, '"str_node" too short.' if gs_porcelain.length < 4

    node_from_gs(gs_porcelain)
  end

  def self.instances?
    ->(node) { node.is_a?(Node) }
  end

  def self.node_from_gs(gs_porcelain)
    status = status(gs_porcelain)
    ary_nodes = "./#{gs_porcelain[3..]}".split(%r{/})

    name = ary_nodes.shift
    if ary_nodes.any?
      children = NodesCollection.create_from_array(ary_nodes, status)
      new(name, children)
    else
      new(name, nil, status)
    end
  end

  private_class_method :node_from_gs

  def self.status(gs_porcelain)
    status = "#{gs_porcelain[0]}+" if gs_porcelain[1] == ' '
    status = gs_porcelain[1] unless gs_porcelain[1] == ' '
    status
  end
  private_class_method :status

  def to_primitive
    if dir?
      { name => children.to_primitive }
    else
      name
    end
  end

  def file?
    children.nil?
  end

  def dir?
    !file?
  end

  def valid?
    return valid_dir? if dir?
    return valid_file? if file?

    false
  end

  # @return [NodesCollection]
  def +(other)
    raise 'not valid' unless valid? && other.valid?
    raise "not a #{self.class}" unless other.is_a?(self.class)

    tmp_children = [children, other.children].compact.inject(&:+)

    NodesCollection.new([self.class.new(name, tmp_children)])
  end

  def <=>(other)
    return (name <=> other.name) if file? == other.file?
    return -1 if dir? && other.file?
    return 1 if file? && other.dir?

    0
  end

  def to_tree_s(depth = 0, open_parents = [0], last: true)
    open_parents << depth

    pre = pre_tree(depth, open_parents, last)

    str_tree = "#{pre}#{color_name}\n"
    str_tree += children.to_tree_s(depth + 1, open_parents) if children

    str_tree
  end

  #   'M'  modified
  def modified?
    status.include?('M')
  end

  #   'A'  added
  def added?
    status.include?('A')
  end

  #   'D'  deleted
  def deleted?
    status.include?('D')
  end

  #   'R'  renamed
  def renamed?
    status.include?('R')
  end

  #   'C'  copied
  def copied?
    status.include?('C')
  end

  #   'U'  updated but unmerged
  def unmerged?
    status.include?('U')
  end

  #   '?' new
  def new?
    status.include?('?')
  end

  #   '+' staged
  def staged?
    status.include?('+')
  end

  private

  def validate_name!(name)
    msg = '"name" must be a String.'
    raise NodeNameError, msg unless name.is_a? String

    msg = '"name" must have at least one character.'
    raise NodeNameError, msg if name.empty?

    msg = '"name" must not contain "/", use create_from_string.'
    raise NodeNameError, msg if name =~ %r{/}
  end

  def color_name
    color_name = ''
    if dir?
      color_name += BashColor::EMB + name
    else
      color_name += BashColor::G if staged?
      color_name += BashColor::R unless staged?
      color_name += "#{name} (#{status})"
    end
    color_name + BashColor::NONE
  end

  # Has a valid name?
  def name_valid?
    name.is_a?(String) &&
      name.length.positive? &&
      name.match(%r{/}).nil?
  end

  # Is a valid dir?
  def valid_dir?
    name_valid? &&
      children.is_a?(NodesCollection) &&
      children.valid?
  end

  # Is a valid file?
  def valid_file?
    name_valid? &&
      children.nil?
  end

  def pre_tree(depth, open_parents, last)
    if depth.zero?
      ''
    elsif depth.positive?
      pre_ary = Array.new(depth).fill('    ')
      indent = self.class.indent - 2

      open_parents.each { |idx| pre_ary[idx] = "│#{' ' * indent} " if pre_ary[idx] == '    ' }

      sibling(depth, indent, last, open_parents, pre_ary)

      pre_ary * ''
    end
  end

  def sibling(depth, indent, last, open_parents, pre_ary)
    if last
      pre_ary[-1] = '└'
      open_parents.delete(depth - 1)
    else
      pre_ary[-1] = '├'
    end
    pre_ary[-1] += "#{'─' * indent} "
  end
end
