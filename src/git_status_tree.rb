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
    Node.collapse_dirs = collapse(options)
    @files = parse_status(`git status --porcelain -z#{untracked_files(options)}`)
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

  # Parse NUL-terminated `git status --porcelain -z` output into porcelain
  # entry strings. Unlike the default output, -z never quotes or escapes
  # paths, so names with spaces, non-ASCII characters, quotes, backslashes
  # or tabs survive intact. Rename/copy entries span two NUL-separated
  # tokens ("<XY> <dest>\0<orig>\0") and are reassembled into the
  # "<XY> <orig> -> <dest>" form the node parser expects.
  def parse_status(raw)
    # Paths are emitted as raw UTF-8 bytes; tag them so names display literally.
    tokens = raw.force_encoding('UTF-8').split("\0")
    files = []
    index = 0
    while index < tokens.length
      entry = tokens[index]
      index += 1
      next if entry.nil? || entry.empty?

      if rename_or_copy?(entry)
        orig = tokens[index]
        index += 1
        files << "#{entry[0, 3]}#{orig} -> #{entry[3..]}"
      else
        files << entry
      end
    end
    files
  end

  def rename_or_copy?(entry)
    status = entry[0, 2]
    status.include?('R') || status.include?('C')
  end

  def indent(options)
    indent = options[:indent] || config || 4
    indent = 2 if indent < 2
    indent = 10 if indent > 10
    indent
  end

  def collapse(options)
    # Command line option takes precedence, then git config, then default (false)
    return options[:collapse] if options.key?(:collapse)

    config_collapse?
  end

  def untracked_files(options)
    # Show untracked files in new directories, like `git status --untracked-files`
    options[:untracked_files] ? ' --untracked-files=all' : ''
  end

  def config
    config = `git config --global status-tree.indent`.strip
    config =~ /\A\d+\z/ ? config.to_i : nil
  end

  def config_collapse?
    config = `git config --global status-tree.collapse`.strip
    config == 'true'
  end
end
