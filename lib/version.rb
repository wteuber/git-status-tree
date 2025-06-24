# frozen_string_literal: true

# Version information for git-status-tree
class GitStatusTree
  VERSION_FILE = File.expand_path('../VERSION', __dir__)
  VERSION = File.exist?(VERSION_FILE) ? File.read(VERSION_FILE).strip : 'unknown'
end
