# encoding: utf-8

class NodeNameError < StandardError; end
class NodeChildrenError < StandardError; end
class NodeTypeError < StandardError; end

class Node
  class << self
    attr_accessor :indent
  end

  attr_accessor :status, :name, :children

  def initialize(name, children = nil, status = nil)
    self.class.indent ||= 4
    raise NodeNameError, '"name" must be a String.' unless name.is_a? String
    name = name.force_encoding('US-ASCII')
    raise NodeNameError, '"name" must have at least one character.' if name.empty?
    raise NodeNameError, '"name" must not contain "/", use create_from_string.' if name =~ /\//
    raise NodeChildrenError, '"children" must be a NodesCollection or nil.' unless children.nil? || children.is_a?(NodesCollection)

    @name = name
    @children = children
    @status = status || []
  end

  def self.create_from_string(gs_porcelain)
    raise NodeTypeError, '"str_node" must be String.' unless gs_porcelain.is_a? String
    raise NodeNameError, '"str_node" too short.' if gs_porcelain.length < 4
    status = if gs_porcelain[1] == ' '
               gs_porcelain[0] + '+'
             else
               gs_porcelain[1]
             end
    path = './' + gs_porcelain[3..-1]
    ary_nodes = path.split(/\//)
    name = ary_nodes.shift

    if ary_nodes.any?
      children = NodesCollection.create_from_array(ary_nodes, status)
      node = self.new(name, children)
    else
      node = self.new(name, nil, status)
    end

    node
  end

  def to_primitive
    if dir?
      {name => children.to_primitive}
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
    raise 'not valid' unless self.valid? && other.valid?
    raise 'not a ' + self.class.to_s unless other.is_a?(self.class)

    result = (if self.name == other.name
        if self.children.nil? && other.children.nil?
          NodesCollection.new([self.class.new(self.name)])
        elsif !self.children.nil? && other.children.nil?
          NodesCollection.new([self.class.new(self.name, self.children)])
        elsif self.children.nil? && !other.children.nil?

          NodesCollection.new([self.class.new(self.name, other.children)])
        else
          NodesCollection.new([self.class.new(self.name, self.children + other.children)])
        end
      else
        NodesCollection.new([self, other].sort!)
      end)

    result
  end

  def <=>(other)
    return (self.name <=> other.name) if (self.file? && other.file?) || (self.dir? && other.dir?)
    return -1 if (self.dir? && other.file?)
    return 1 if (self.file? && other.dir?)
    0
  end

  def to_tree_s(depth = 0, open_parents = [0], last = true)
    open_parents << depth

    pre = (if depth == 0
        ''
      elsif depth > 0
        pre_ary = Array.new(depth).fill('    ')

        indent = self.class.indent - 2
        open_parents.each do |idx|
          pre_ary[idx] = '│' + (' ' * indent) + ' ' if pre_ary[idx] == '    '
        end

        if last
          pre_ary[-1] = '└'
          open_parents.delete(depth-1)
        else
          pre_ary[-1] = '├'
        end
        pre_ary[-1] += ('─' * indent) + ' '


        pre_ary * ''
      end)

    color_name = ''
    if dir?
      color_name += BashColor::EMB + name
    else #file?
      if staged?
        color_name += BashColor::G
      else
        color_name += BashColor::R
      end
      color_name += name + ' (' + status + ')'
    end
    color_name +=  BashColor::NONE


    str_tree = pre + color_name + "\n"
    str_tree << children.to_tree_s(depth + 1, open_parents) if children

    str_tree
  end

  #   'M'  modified
  def modified?
    self.status.include?('M')
  end

  #   'A'  added
  def added?
    self.status.include?('A')
  end

  #   'D'  deleted
  def deleted?
    self.status.include?('D')
  end

  #   'R'  renamed
  def renamed?
    self.status.include?('R')
  end

  #   'C'  copied
  def copied?
    self.status.include?('C')
  end

  #   'U'  updated but unmerged
  def unmerged?
    self.status.include?('U')
  end

  #   '?' new
  def new?
    self.status.include?('?')
  end

  #   '+' staged
  def staged?
    self.status.include?('+')
  end

  private
  # Has a valid name?
  def name_valid?
    name &&
      name.is_a?(String) &&
      name.encoding.to_s.eql?("US-ASCII") &&
      name.match(/\//).nil?
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
end
