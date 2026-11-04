[![CI](https://github.com/wteuber/git-status-tree/actions/workflows/ci.yml/badge.svg)](https://github.com/wteuber/git-status-tree/actions/workflows/ci.yml) [![Gem Version](https://badge.fury.io/rb/git-status-tree.svg)](https://badge.fury.io/rb/git-status-tree) [![License: MIT or GPL-2.0](https://img.shields.io/badge/license-MIT%20or%20GPL--2.0-blue.svg)](LICENSE) [![Ruby Version](https://img.shields.io/badge/ruby-%3E%3D%202.6-ruby.svg)](https://www.ruby-lang.org)

# git-status-tree

git-status-tree (https://github.com/wteuber/git-status-tree) is a command line tool that  
helps you keeping track of changes in your git repository. Similar to the `tree` command  
(https://github.com/nodakai/tree-command), git-status-tree recursively lists directories  
and files. Run `git tree` in the command line to list all files in your git repository that are  
untracked (?), have been added (A), modified (M), deleted (D), or renamed (R). The colored output  
shows whether a file has been added/staged (green)(+) or not (red). The current status  
of each file is appended to it. For renamed files, the tree structure shows the original  
location with an arrow pointing to the new name or path. Run `git tree <commit>` or  
`git tree <c1> <c2>` to see the files changed in or between commits the same way  
(see [Inspecting commits](#inspecting-commits)).

See [CHANGELOG.md](CHANGELOG.md) for a list of changes between versions.
___
## Installation
git-status-tree is available on [rubygems.org](https://rubygems.org/gems/git-status-tree).
Install git-status-tree by running:
```
gem install git-status-tree
```

Installing the gem adds the `git tree` alias to your global git config and sets
the `status-tree.*` defaults (see [Configuration](#configuration)) unless you
have already set them.

## Usage
Start using git-status-tree in your terminal by running:
```
git tree
```
#### Example Output
<img width="504" alt="image" src="https://github.com/user-attachments/assets/f1f15556-bf95-4fe8-8231-a8858e80f20e" />

## Inspecting commits
The same tree rendering can inspect history. Pass one or two commits (any
revision git accepts: a SHA, `HEAD`, `HEAD~3`, a branch, or a tag):

```
git tree                # working-tree status (default)
git tree <commit>       # files changed in <commit> (vs. its first parent)
git tree <c1> <c2>      # files that differ between the two commits
git tree <c1>..<c2>     # same as above, as a single range token
```

Commit-mode entries render in cyan (distinct from the green=staged /
red=dirty working-tree palette) with the git status letter: `A` added,
`M` modified, `D` deleted, `R` renamed, `T` type-changed. Renames show as
`old -> new (R)`. The `-i/--indent` and `-c/--collapse` options apply in all
modes.

Notes:
- `-u/--untracked-files` is meaningless for commits and is ignored.
- A root commit (no parent) lists every file as added.
- A single-commit view of a **merge** commit shows its changes vs. its first
  parent.
- In a range, an omitted side defaults to `HEAD` (`<c1>..` means `<c1>..HEAD`).
- The symmetric-difference form `<c1>...<c2>` is not supported (use `..`).

## Options
```
Usage: git-status-tree [options] [<commit> [<commit>] | <commit>..<commit>]
    -i, --indent INDENT              Set indentation (2-10 spaces)
    -c, --collapse                   Collapse directories containing only another directory
    -u, --untracked-files            Show untracked files in new directories
    -v, --version                    Show version
    -h, --help                       Show this help message
```

Usage errors (an invalid option, more than two commits, a bad revision) are
printed to stderr and exit with status 1.

**Note:** Due to how git handles aliases, when using `git tree --help`, git will show the alias expansion instead of the help message. Use `git tree -h` to see the help message.

## Compatibility
git-status-tree supports:
* Git (http://git-scm.com): version 1.8+ for the working-tree view; 2.31+ for
  the commit views (`git tree <commit> [<commit>]`)
* Ruby (http://www.ruby-lang.org): version 2.6+

Ruby 2.6 is the support floor because it is the stock Ruby shipped with macOS,
so git-status-tree runs out of the box without installing a newer Ruby. The
runtime uses only the standard library (no gem dependencies), and RuboCop's
`TargetRubyVersion` is pinned to 2.6 to flag any syntax or APIs newer than 2.6
before they reach a user on system Ruby. Newer Ruby versions (3.x, 4.x) are
fully supported as well.

## Configuration
Settings are read from your **global** git config only.

Set the indentation as you like (2-10), default is 4. The `-i` option overrides it.
```
git config --global status-tree.indent <indent>
```

Set whether to collapse directories by default, default is false. The `-c`
option turns collapsing on for a single run.
```
git config --global status-tree.collapse <true|false>
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

git tree -ci 2
.
├ lib/version.rb -> git_tree_version.rb (R+)
├ test
│ ├ node/test_node_class.rb -> test/node_class_test.rb (R+)
│ ├ staged.txt (A+)
│ └ untracked.txt (?)
├ DELETEME.txt (D+)
└ README.md (M)

# reset repo
git reset HEAD --hard
git clean -xdf
```

## Uninstall
```
gem uninstall git-status-tree
```

Uninstalling removes the `git tree` alias and all `status-tree.*` settings from
your global git config.
___
## Development

1. Clone this repository
   * `git clone https://github.com/wteuber/git-status-tree.git`
   * `cd git-status-tree`
2. Install development dependencies (Rake, RuboCop)
    * `bundle install` (the locked Bundler 4 and RuboCop need a modern Ruby;
      `.ruby-version` pins the Ruby used for development)
3. Run tests
    * `rake` - Run all tests and RuboCop checks (default)
    * `rake test` - Run all tests
    * `rake test:node` - Run Node class tests only
    * `rake test:nodes_collection` - Run NodesCollection tests only
    * `rake test:git_status_tree` - Run GitStatusTree unit tests only
    * `rake test:integration` - Run integration tests only
    * `rake test:utilities` - Run version tests only
    * `ruby test/coverage.rb` (or `rake coverage`) - Run the suite with the
      coverage gate (what CI runs)
    * The suite runs on minitest (bundled with Ruby) and measures coverage with
      the standard library's `coverage` extension, so `ruby test/coverage.rb`
      needs no gems or Bundler and runs on every supported Ruby (2.6+). Tests
      require 100% library coverage.
    * Tests point git's global config at a temporary file (`GIT_CONFIG_GLOBAL`,
      so running the suite needs git 2.32+); they never read or change your
      global git config.
4. Run RuboCop separately (optional)
    * `bundle exec rubocop`
    * To auto-correct offenses: `bundle exec rubocop -a`
5. Run git-status-tree from repository
    * `./bin/git-status-tree`
6. Record notable changes in [CHANGELOG.md](CHANGELOG.md)
    * The changelog follows [Keep a Changelog 1.1.0](https://keepachangelog.com/en/1.1.0/)
      and the project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).
    * Add entries under `## [Unreleased]`, grouped by type: `Added`, `Changed`,
      `Deprecated`, `Removed`, `Fixed`, `Security`.
    * On release, rename `[Unreleased]` to `[x.y.z] - YYYY-MM-DD` and update the
      compare links at the bottom of the file.
7. Build and install local gem
   * `gem build git-status-tree.gemspec`
   * `gem install git-status-tree-3.7.0.gem`
8. Push new version to rubygems (maintainers only)
   * `gem push git-status-tree-3.7.0.gem`
