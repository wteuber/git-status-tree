# frozen_string_literal: true

require File.join File.dirname(__FILE__), '../lib/node'
require File.join File.dirname(__FILE__), '../lib/node_collapsing'
require File.join File.dirname(__FILE__), '../lib/nodes_collection'
require File.join File.dirname(__FILE__), '../lib/bash_color'
require File.join File.dirname(__FILE__), '../lib/version'

# Main class for generating and displaying git status as a tree structure
class GitStatusTree
  attr_reader :files, :nodes, :tree

  def initialize(options = {})
    Node.indent = indent(options)
    Node.collapse_dirs = options[:collapse] || false
    @files = `git status --porcelain`.split("\n")
    @nodes = files.map { |file| Node.create_from_string file }
    @tree = nodes.reduce { |a, i| (a + i).nodes[0] }
  end

  def to_s
    if tree.nil?
      '(working directory clean)'
    else
      tree.to_tree_s
    end
  end

  private

  def indent(options)
    indent = options[:indent] || config || 4
    indent = 2 if indent < 2
    indent = 10 if indent > 10
    indent
  end

  def config
    config = `git config --global status-tree.indent`.strip
    config =~ /\A\d+\z/ ? config.to_i : nil
  end
end
