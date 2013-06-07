[![Build Status]
(https://travis-ci.org/knugie/git-status-tree.png?branch=master)]
(https://travis-ci.org/knugie/git-status-tree)

git-status-tree
=============================================

git-status-tree (https://github.com/knugie/git-status-tree) is a command line
tool that helps you keeping track of changes in your git repository. Similar to
the tree command (http://mama.indstate.edu/users/ice/tree), git-status-tree
recursively lists directories and files like this:

    .
    ├── bin
    │   ├── git-status-tree
    │   ├── install
    │   └── uninstall
    ├── lib
    │   ├── bash_color.rb
    │   ├── node.rb
    │   └── nodes_collection.rb
    ├── src
    │   ├── git_status_tree.rb
    │   └── git-status-tree.rb
    ├── test
    │   ├── node
    │   │   ├── test_node_attributes.rb
    │   │   ├── test_node_children_error.rb
    │   │   ├── test_node_class.rb
    │   │   ├── test_node_create_from_string.rb
    │   │   ├── test_node_instance.rb
    │   │   └── test_node_name_error.rb
    │   ├── nodes_collection
    │   │   ├── test_nodes_collection_class.rb
    │   │   └── test_nodes_collection_instance.rb
    │   └── test_git-status-tree
    ├── DELETEME.txt
    ├── GPL-LICENSE
    ├── LICENSE
    ├── MIT-LICENSE
    ├── Rakefile
    ├── README.md
    └── VERSION

Run "git tree" in the command line to list the files in your git repository you
added, modified or deleted. The colored output indicates whether files have been
staged (green) or not (red). In addition the current status of each file is
appended to the list. git-status-tree requires git 1.8+ (http://git-scm.com)
and ruby 1.8+ (http://www.ruby-lang.org).

Sample
------
    $ git tree
    .
    ├── test
    │   └── TODO.txt (?)
    ├── DELETEME.txt (D)
    └── README.md (M)

Install
------
    $ git clone https://github.com/knugie/git-status-tree.git
    $ cd git-status-tree
    $ ./bin/install

Config
------
Set the indentation as you like, default is 4.

    $ git config --global status-tree.indent <indent>


Uninstall
------
    $ cd git-status-tree
    $ ./bin/uninstall

Try it
------
    $ git clone https://github.com/knugie/git-status-tree.git
    $ cd git-status-tree
    $ ./bin/install
    $ echo "modified" >> README.md
    $ echo "added" > test/TODO.txt
    $ rm DELETEME.txt
    $ git tree
    .
    ├── test
    │   └── TODO.txt (?)
    ├── DELETEME.txt (D)
    └── README.md (M)
