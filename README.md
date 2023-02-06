[![CircleCI Status](https://circleci.com/gh/knugie/git-status-tree/tree/master.svg?style=shield)](https://circleci.com/gh/knugie/git-status-tree/tree/master)
[![Gem Version](https://badge.fury.io/rb/git-status-tree.svg)](https://badge.fury.io/rb/git-status-tree)

# git-status-tree

git-status-tree (https://github.com/knugie/git-status-tree) is a command line tool that  
helps you keeping track of changes in your git repository. Similar to the `tree` command  
(https://github.com/nodakai/tree-command), git-status-tree recursively lists directories  
and files. Run `git tree` in the command line to list all files in your git repository that are  
untracked (?) or have been added (A), modified (M) or deleted (D). The colored output  
shows whether a file has been added/staged (green)(+) or not (red). The current status  
of each file is appended to it.
___
## Installation
**git-status-tree** is available on [rubygems.org](https://rubygems.org/gems/git-status-tree). Install git-status-tree running:
```
gem install git-status-tree
```

## Example
![image](https://user-images.githubusercontent.com/1446195/134486179-290820c6-4a8c-4cf3-8707-43adacb77b4d.png)

## Compatibility
**git-status-tree** supports:
* Git (http://git-scm.com): version 1.8+
* Ruby (http://www.ruby-lang.org): version 2.7+

## Configuration
Set the indentation as you like, default is 4.
```
git config --global status-tree.indent <indent>
```

## Try it
```
gem install git-status-tree
git clone https://github.com/knugie/git-status-tree.git
cd git-status-tree
echo "change" >> README.md
echo "add untracked" > test/untracked.txt
rm DELETEME.txt
git add DELETEME.txt
echo "add staged" > test/staged.txt
git add test/staged.txt

git tree
.
├── test
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
   * `git clone https://github.com/knugie/git-status-tree.git`
   * `cd git-status-tree`
2. Install dependencies
    * `bundle install`
3. Run tests
    * `./test/test_git_status_tree`
4. Run git-status-tree from repository
    * `./bin/git-status-tree`
5. Build and install local gem
   * `gem build git-status-tree.gemspec`
   * `gem install git-status-tree-2.0.0.gem`
