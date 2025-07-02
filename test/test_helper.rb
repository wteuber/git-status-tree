# frozen_string_literal: true

# Load SimpleCov initialization before anything else
require_relative 'simplecov_init'

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
$LOAD_PATH.unshift File.expand_path('../src', __dir__)

require 'test/unit'
require 'tmpdir'
require 'fileutils'

require 'bash_color'
require 'node_collapsing'
require 'node'
require 'nodes_collection'
require 'git_status_tree'
require 'version'
