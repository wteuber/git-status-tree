# encoding: utf-8

require File.join File.dirname(__FILE__), '../lib/node'
require File.join File.dirname(__FILE__), '../lib/nodes_collection'
require File.join File.dirname(__FILE__), '../lib/bash_color'
require File.join File.dirname(__FILE__), '../src/git_status_tree'

# GIT STATUS
#   ' '  unmodified
#   'M'  modified
#   'A'  added
#   'D'  deleted
#   'R'  renamed
#   'C'  copied
#   'U'  updated but unmerged
#   '??' other
