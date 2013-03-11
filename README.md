git-status-tree
=============================================

The tree command ([http://mama.indstate.edu/users/ice/tree/])
recursively lists directories and files like that:

    $ tree --dirsfirst
    .
    ├── bin
    │   └── git-status-tree
    ├── lib
    │   ├── bash_color.rb
    │   ├── node.rb
    │   └── nodes_collection.rb
    ├── src
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
    ├── README.md
    └── VERSION

The git-status-tree command ([https://github.com/knugie/git-status-tree])
also prints this tree, containing only the the files listed by git-status.
The output is colored. In order to use git-status-tree you need to install
Ruby ([http://www.ruby-lang.org]) and of course Git is needed as well.

Try it!
------
    $ git clone https://github.com/knugie/git-status-tree.git
    $ cd git-status-tree
    $ echo "modified" >> README.md
    $ echo "added" > test/TODO.txt
    $ rm VERSION
    $ echo "I need to install Ruby."
    $ ruby ./bin/git-status-tree
    .
    ├── test
    │   └── TODO.txt (?)
    ├── README.md (M)
    └── VERSION (D)

