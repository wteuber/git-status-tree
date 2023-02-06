# frozen_string_literal: true

require File.join File.dirname(__FILE__), '../lib/node'
require File.join File.dirname(__FILE__), '../lib/nodes_collection'
require File.join File.dirname(__FILE__), '../lib/bash_color'
require File.join File.dirname(__FILE__), '../src/git_status_tree'

# GitStatusTree
# use GitStatusTree.new.to_s to print the current git-status-tree
class GitStatusTree
  attr_reader :files, :nodes, :tree

  def initialize(options = {})
    Node.indent = indent(options)
    @files = `git status --porcelain`.split(/\n/)
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
