class GitStatusTree
  attr_reader :files, :nodes, :tree
  
  def initialize(options = {})
    config = %x(git config --global status-tree.indent).strip
    config = (config =~ /\A\d+\z/) ? config.to_i : nil
    indent = options[:indent] || config || 4
    indent = 2 if indent < 2
    indent = 10 if indent > 10
    Node.indent = indent
    @files = (%x(git status --porcelain)).split(/\n/)
    @nodes = files.map{|file| Node.create_from_string file}
    @tree = nodes.reduce{|a, i| (a+i).nodes[0]}
  end
  
  def to_s
    if tree.nil?
      '(working directory clean)'
    else
      tree.to_tree_s
    end
  end
end
