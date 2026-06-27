# frozen_string_literal: true

require File.join File.dirname(__FILE__), '../lib/node'
require File.join File.dirname(__FILE__), '../lib/node_collapsing'
require File.join File.dirname(__FILE__), '../lib/nodes_collection'
require File.join File.dirname(__FILE__), '../lib/bash_color'
require File.join File.dirname(__FILE__), '../lib/version'

# Main class for generating and displaying git status as a tree structure
class GitStatusTree
  # Raised when a positional commit argument is not a valid revision.
  class RevisionError < StandardError; end

  attr_reader :files, :nodes, :tree

  def initialize(options = {})
    commits = Array(options[:commits])
    configure_node(options, commits)
    @files = source_files(commits, options)
    @nodes = files.map { |file| Node.create_from_string file }
    @tree = nodes.reduce { |a, i| (a + i).nodes[0] }
  end

  def to_s
    if tree.nil?
      Node.mode == :commit ? '(no changes)' : '(working directory clean)'
    else
      tree.to_tree_s
    end
  end

  private

  def configure_node(options, commits)
    Node.indent = indent(options)
    Node.collapse_dirs = collapse(options)
    Node.mode = commits.empty? ? :status : :commit
  end

  # Dispatch on the number of commit args: no commits keeps the working-tree
  # status view; one or two commits switch to the git diff-tree history view.
  def source_files(commits, options)
    if commits.empty?
      parse_status(`git status --porcelain -z#{untracked_files(options)}`)
    else
      parse_diff_tree(diff_tree_output(commits))
    end
  end

  def diff_tree_output(commits)
    refs = validate_revs!(commits)
    # -M enables rename detection (no -C: copy detection is off by default in
    # git and is slower/noisier), -r recurses into subtrees, --no-commit-id
    # suppresses the leading SHA line, --root lists every file as added for a
    # root commit (no parent), -z gives unambiguous paths.
    `git diff-tree --no-commit-id --name-status -M -r --root -z #{refs.join(' ')}`
  end

  # Translate diff-tree -z output into the porcelain entry strings the node
  # pipeline already understands. The stream is "<status>\0<path>\0 …", with
  # rename/copy entries spanning a triplet "<status>\0<old>\0<new>\0".
  def parse_diff_tree(raw)
    tokens = raw.force_encoding('UTF-8').split("\0")
    files = []
    index = 0
    while index < tokens.length
      status = tokens[index]
      index += 1
      next if status.nil? || status.empty?

      index = append_diff_entry(files, tokens, index, status[0])
    end
    files
  end

  # Append a single porcelain entry and return the advanced token index.
  # The status letter goes in the porcelain Y column so Node.status reads it
  # verbatim (no staged "+" suffix), and commit-mode rendering colors it cyan.
  def append_diff_entry(files, tokens, index, code)
    if %w[R C].include?(code)
      old = tokens[index]
      new = tokens[index + 1]
      files << " #{code} #{old} -> #{new}"
      index + 2
    else
      files << " #{code} #{tokens[index]}"
      index + 1
    end
  end

  # Normalize positional args into resolved SHAs, expanding a single "A..B"
  # token into two endpoints. "A...B" is rejected: diff-tree does not honor
  # symmetric-difference semantics and would silently return nothing.
  def validate_revs!(commits)
    if commits.length == 1 && commits[0].include?('..')
      if commits[0].include?('...')
        raise RevisionError, "fatal: '#{commits[0]}': '...' range is not supported; use 'A..B'"
      end

      commits = commits[0].split('..', 2)
    end
    commits.map { |rev| validate_rev!(rev) }
  end

  def validate_rev!(rev)
    sha = `git rev-parse --verify --quiet #{rev}^{commit} 2>/dev/null`.strip
    raise RevisionError, "fatal: bad revision '#{rev}'" if sha.empty?

    sha
  end

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
