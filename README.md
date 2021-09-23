[![Build Status](https://travis-ci.org/knugie/git-status-tree.png?branch=master)](https://travis-ci.org/knugie/git-status-tree)

# git-status-tree

git-status-tree (https://github.com/knugie/git-status-tree) is a command line tool that  
helps you keeping track of changes in your git repository. Similar to the `tree` command  
(https://github.com/nodakai/tree-command), git-status-tree recursively lists directories  
and files. Run `git tree` in the command line to list all files in your git repository that are  
untracked (?) or have been added (A), modified (M) or deleted (D). The colored output  
shows whether a file has been added/staged (green)(+) or not (red). The current status  
of each file is appended to it.

## Example
![image](https://user-images.githubusercontent.com/1446195/134486179-290820c6-4a8c-4cf3-8707-43adacb77b4d.png)

## Requirements
* Git (http://git-scm.com): version 1.8+
* Ruby (http://www.ruby-lang.org): version 1.8+

## Install
```
git clone https://github.com/knugie/git-status-tree.git
cd git-status-tree
./bin/install
```

## Config
Set the indentation as you like, default is 4.
```
git config --global status-tree.indent <indent>
```

## Uninstall
```
cd path/to/git-status-tree
./bin/uninstall
```

## Try it
```
git clone https://github.com/knugie/git-status-tree.git
cd git-status-tree
./bin/install
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
