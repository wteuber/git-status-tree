[![Build Status](https://travis-ci.org/knugie/git-status-tree.png?branch=master)](https://travis-ci.org/knugie/git-status-tree)

# git-status-tree

git-status-tree (https://github.com/knugie/git-status-tree) is a command line tool  
that helps you keeping track of changes in your git repository. Similar to the `tree`  
command (https://github.com/nodakai/tree-command), git-status-tree recursively  
lists directories and files. Run `git tree` in the command line to list all files in your  
git repository that have been added (A), modified (M) or deleted (D). The colored  
output indicates whether a file has been staged (green)(+) or not (red). The current  
status of each file is appended to it.

## Example
![image](https://user-images.githubusercontent.com/1446195/134482902-57b38014-c417-4dda-946e-716f50c27d9e.png)

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
echo "add unstaged" > test/unstaged.txt
rm DELETEME.txt
git add DELETEME.txt
echo "add staged" > test/staged.txt
git add test/staged.txt

git tree
.
├── test
│   ├── staged.txt (A+)
│   └── unstaged.txt (?)
├── DELETEME.txt (D+)
└── README.md (M)

# reset repo
git reset HEAD --hard
git clean -xdf
```
