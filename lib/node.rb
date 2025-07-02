# frozen_string_literal: true

require_relative 'node_collapsing'

class NodeNameError < StandardError; end
class NodeChildrenError < StandardError; end
class NodeTypeError < StandardError; end

# A Node represents a file or directory in the git-status-tree
class Node
  include NodeCollapsing

  class << self
    attr_accessor :indent, :collapse_dirs
  end

  attr_accessor :status, :name, :children

  def initialize(name, children = nil, status = nil)
    self.class.indent ||= 4
    self.class.collapse_dirs ||= false
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

    # Handle renamed files specially
    if status.include?('R')
      node_from_renamed_file(gs_porcelain, status)
    else
      # Original logic for non-renamed files
      node_from_regular_file(gs_porcelain, status)
    end
  end

  def self.node_from_renamed_file(gs_porcelain, status)
    paths_part = gs_porcelain[3..]
    return node_from_regular_file(gs_porcelain, status) unless paths_part.include?(' -> ')

    old_path, new_path = paths_part.split(' -> ')
    old_dir = File.dirname(old_path)

    rename_display = build_rename_display(old_path, new_path)

    build_node_structure(old_dir, rename_display, status)
  end

  private_class_method :node_from_renamed_file

  def self.build_rename_display(old_path, new_path)
    old_dir = File.dirname(old_path)
    new_dir = File.dirname(new_path)
    old_filename = File.basename(old_path)
    new_filename = File.basename(new_path)

    if old_dir == new_dir
      "#{old_filename} -> #{new_filename}"
    else
      "#{old_filename} -> #{new_path}"
    end
  end
  private_class_method :build_rename_display

  def self.build_node_structure(dir_path, leaf_name, status)
    if dir_path == '.'
      # File is in root directory
      new(leaf_name, nil, status)
    else
      # File is in subdirectory
      ary_nodes = "./#{dir_path}".split(%r{/})

      name = ary_nodes.shift
      # Add the leaf_name as the last element
      ary_nodes << leaf_name
      children = NodesCollection.create_from_array(ary_nodes, status)
      new(name, children)
    end
  end
  private_class_method :build_node_structure

  def self.node_from_regular_file(gs_porcelain, status)
    ary_nodes = "./#{gs_porcelain[3..]}".split(%r{/})

    name = ary_nodes.shift
    if ary_nodes.any?
      children = NodesCollection.create_from_array(ary_nodes, status)
      new(name, children)
    else
      new(name, nil, status)
    end
  end
  private_class_method :node_from_regular_file

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

  def file? = children.nil?

  def dir? = !file?

  def valid?
    file? ? valid_file? : valid_dir?
  end

  def +(other)
    raise 'not valid' unless valid? && other.valid?
    raise "not a #{self.class}" unless other.is_a?(self.class)

    tmp_children = [children, other.children].compact.inject(&:+)

    NodesCollection.new([self.class.new(name, tmp_children)])
  end

  def <=>(other)
    return (name <=> other.name) if file? == other.file?

    dir? && other.file? ? -1 : 1
  end

  def to_tree_s(depth = 0, open_parents = [0], last: true)
    open_parents << depth

    pre = pre_tree(depth, open_parents, last)

    # Handle directory collapsing if enabled
    if self.class.collapse_dirs && collapsible?
      render_collapsed_tree(pre, depth, open_parents)
    else
      # Normal rendering
      str_tree = "#{pre}#{color_name}\n"
      str_tree += children.to_tree_s(depth + 1, open_parents) if children
      str_tree
    end
  end

  def modified? = status.include?('M')
  def added? = status.include?('A')
  def deleted? = status.include?('D')
  def renamed? = status.include?('R')
  def copied? = status.include?('C')
  def unmerged? = status.include?('U')
  def new? = status.include?('?')
  def staged? = status.include?('+')

  private

  def validate_name!(name)
    msg = '"name" must be a String.'
    raise NodeNameError, msg unless name.is_a? String

    msg = '"name" must have at least one character.'
    raise NodeNameError, msg if name.empty?

    msg = '"name" must not contain "/", use create_from_string.'
    # Allow forward slashes in rename displays (containing " -> ")
    raise NodeNameError, msg if name =~ %r{/} && !name.include?(' -> ')
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

  def name_valid?
    name.is_a?(String) &&
      name.length.positive? &&
      (name.match(%r{/}).nil? || name.include?(' -> '))
  end

  def valid_dir?
    name_valid? &&
      children.is_a?(NodesCollection) &&
      children.valid?
  end

  def valid_file?
    name_valid? &&
      children.nil?
  end

  def pre_tree(depth, open_parents, last)
    return '' if depth.zero?
    return '' unless depth.positive?

    pre_ary = build_pre_array(depth, open_parents)
    sibling(depth, self.class.indent - 2, last, open_parents, pre_ary)
    pre_ary * ''
  end

  def build_pre_array(depth, open_parents)
    spaces = ' ' * self.class.indent
    pre_ary = Array.new(depth).fill(spaces)
    indent = self.class.indent - 2

    open_parents.each do |idx|
      pre_ary[idx] = "│#{' ' * indent} " if pre_ary[idx] == spaces
    end

    pre_ary
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
