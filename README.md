[![Gem Version](https://badge.fury.io/rb/git-status-tree.svg)](https://badge.fury.io/rb/git-status-tree)

# git-status-tree

git-status-tree (https://github.com/wteuber/git-status-tree) is a command line tool that  
helps you keeping track of changes in your git repository. Similar to the `tree` command  
(https://github.com/nodakai/tree-command), git-status-tree recursively lists directories  
and files. Run `git tree` in the command line to list all files in your git repository that are  
untracked (?), have been added (A), modified (M), deleted (D), or renamed (R). The colored output  
shows whether a file has been added/staged (green)(+) or not (red). The current status  
of each file is appended to it. For renamed files, the tree structure shows the original  
location with an arrow pointing to the new name or path.

See [CHANGELOG.md](CHANGELOG.md) for a list of changes between versions.
___
## Installation
git-status-tree is available on [rubygems.org](https://rubygems.org/gems/git-status-tree).
Install git-status-tree by running:
```
gem install git-status-tree
```

## Usage
Start using git-status-tree in your terminal by running:
```
git tree
```
#### Example Output
<img width="504" alt="image" src="https://github.com/user-attachments/assets/f1f15556-bf95-4fe8-8231-a8858e80f20e" />

## Options
```
-i, --indent INDENT    Set indentation (2-10 spaces)
-v, --version          Show version
-h                     Show help message
```

**Note:** Due to how git handles aliases, when using `git tree --help`, git will show the alias expansion instead of the help message. Use `git tree -h` to see the help message.

## Compatibility
git-status-tree supports:
* Git (http://git-scm.com): version 1.8+
* Ruby (http://www.ruby-lang.org): version 3.3+

## Configuration
Set the indentation as you like, default is 4.
```
git config --global status-tree.indent <indent>
```

## Try it
```
gem install git-status-tree
git clone https://github.com/wteuber/git-status-tree.git
cd git-status-tree

echo "change" >> README.md
echo "add untracked" > test/untracked.txt
rm DELETEME.txt
git add DELETEME.txt
echo "add staged" > test/staged.txt
git add test/staged.txt
git mv lib/version.rb lib/git_tree_version.rb
git mv test/node/test_node_class.rb test/node_class_test.rb
git tree
.
├── lib
│   └── version.rb -> git_tree_version.rb (R+)
├── test
│   ├── node
│   │   └── test_node_class.rb -> test/node_class_test.rb (R+)
│   ├── staged.txt (A+)
│   └── untracked.txt (?)
├── DELETEME.txt (D+)
└── README.md (M)

# reset repo
git reset HEAD --hard
git clean -xdf
```

## Uninstall
```
gem uninstall git-status-tree
```
___
## Development

1. Clone this repository
   * `git clone https://github.com/wteuber/git-status-tree.git`
   * `cd git-status-tree`
2. Install dependencies
    * `bundle install`
3. Run tests
    * `rake` - Run all tests and RuboCop checks (default)
    * `rake test` - Run all tests with code coverage only
    * `rake test:node` - Run Node class tests only
    * `rake test:nodes_collection` - Run NodesCollection tests only
    * `rake test:integration` - Run integration tests
    * `rake test:utilities` - Run utility tests (RuboCop, SimpleCov, Version)
    * `rake test_no_coverage` - Run tests without code coverage
    * `rake all` - Run tests and RuboCop checks
    * SimpleCov generates code coverage reports in `coverage/`
    * Coverage reports available in HTML and JSON formats
    * Tests require 100% code coverage
4. Run RuboCop separately (optional)
    * `bundle exec rubocop`
    * To auto-correct offenses: `bundle exec rubocop -a`
5. Run git-status-tree from repository
    * `./bin/git-status-tree`
6. Build and install local gem
   * `gem build git-status-tree.gemspec`
   * `gem install git-status-tree-3.2.0.gem`
