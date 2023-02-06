# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name                  = 'git-status-tree'
  s.required_ruby_version = '>= 2.7'
  s.version               = '2.0.0'
  s.licenses              = ['MIT', 'GPL-2.0']
  s.summary               = 'git status in file tree format'
  s.description           = 'git-status-tree is a command line tool that shows git repository changes in a file tree.'
  s.authors               = ['Wolfgang Teuber']
  s.email                 = 'knugie@gmx.net'
  s.files                 = Dir['{lib/*.rb,src/*.rb,bin/*}'] + Dir['ext/git_tree/Makefile']
  s.require_paths         = ['lib']
  s.executables           = ['git-status-tree']
  s.extensions            = Dir['ext/git_tree/extconf.rb']
  s.homepage              = 'https://github.com/knugie/git-status-tree'
  s.metadata              = { 'source_code_uri' => 'https://github.com/knugie/git-status-tree' }
end
