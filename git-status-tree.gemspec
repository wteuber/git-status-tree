# frozen_string_literal: true

require_relative 'lib/version'

Gem::Specification.new do |s|
  s.name                  = 'git-status-tree'
  s.required_ruby_version = '>= 3.3'
  s.version               = GitStatusTree::VERSION
  s.licenses              = ['MIT', 'GPL-2.0']
  s.summary               = 'git status in file tree format'
  s.description           = 'git-status-tree is a command line tool that shows git repository changes in a file tree.'
  s.authors               = ['Wolfgang Teuber']
  s.email                 = 'knugie@gmx.net'
  s.files                 = Dir['{lib/*.rb,src/*.rb,bin/*}'] + Dir['ext/git_tree/Makefile'] + ['VERSION']
  s.require_paths         = ['lib']
  s.executables           = ['git-status-tree']
  s.extensions            = Dir['ext/git_tree/extconf.rb']
  s.homepage              = 'https://github.com/wteuber/git-status-tree'
  s.metadata              = { 'source_code_uri' => 'https://github.com/wteuber/git-status-tree',
                              'rubygems_mfa_required' => 'true' }
end
