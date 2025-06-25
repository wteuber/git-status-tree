# frozen_string_literal: true

class GitStatusTree
  VERSION_FILE = File.expand_path('../VERSION', __dir__)
  VERSION = File.exist?(VERSION_FILE) ? File.read(VERSION_FILE).strip : 'unknown'
end
