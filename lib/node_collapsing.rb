# frozen_string_literal: true

# Module for directory collapsing functionality
module NodeCollapsing
  # Check if this directory can be collapsed (only contains one child, either file or directory)
  def collapsible?
    return false unless dir?
    return false unless children && children.nodes.length == 1
    return false if name == '.' # Never collapse the root node

    true
  end

  # Get the collapsed path for display
  def collapsed_path
    return name unless collapsible?

    path_parts = [name]
    build_collapsed_path_parts(path_parts)
    path_parts.join('/')
  end

  # Get the deepest node in a collapsible chain
  def deepest_collapsible_node
    current = self

    current = current.children.nodes.first while current.collapsible? && current.children.nodes.first.dir?

    current
  end

  # Check if this is a collapsed path ending with a file
  def collapsed_with_file?
    return false unless collapsible?

    deepest = deepest_collapsible_node
    deepest.children && deepest.children.nodes.length == 1 && deepest.children.nodes.first.file?
  end

  private

  def build_collapsed_path_parts(path_parts)
    current = self

    # Traverse through collapsible directories
    while current.collapsible? && current.children.nodes.first.dir?
      child = current.children.nodes.first
      path_parts << child.name
      current = child
    end

    # Add file if the last child is a file
    append_file_to_path(current, path_parts)
  end

  def append_file_to_path(node, path_parts)
    return unless node.children && node.children.nodes.length == 1

    child = node.children.nodes.first
    path_parts << child.name if child.file?
  end

  def render_collapsed_tree(pre, depth, open_parents)
    display_name = collapsed_path

    if collapsed_with_file?
      render_collapsed_file(pre, display_name)
    else
      render_collapsed_directory(pre, display_name, depth, open_parents)
    end
  end

  def render_collapsed_file(pre, display_name)
    deepest = deepest_collapsible_node
    file_node = deepest.children.nodes.first
    "#{pre}#{color_collapsed_file(display_name, file_node.status)}\n"
  end

  def render_collapsed_directory(pre, display_name, depth, open_parents)
    str_tree = "#{pre}#{color_collapsed_name(display_name)}\n"
    deepest = deepest_collapsible_node
    # Only render children if they exist and have nodes
    str_tree += deepest.children.to_tree_s(depth + 1, open_parents) if deepest.children&.nodes&.any?
    str_tree
  end

  def color_collapsed_name(display_name)
    BashColor::EMB + display_name + BashColor::NONE
  end

  def color_collapsed_file(display_path, status)
    # Split the path to separate directories from the file
    parts = display_path.split('/')
    file_name = parts.pop
    dir_path = parts.join('/')

    if dir_path.empty?
      # No directories, just the file
      color_file_with_status(file_name, status)
    else
      # Directories in blue, file colored by status
      "#{BashColor::EMB}#{dir_path}/#{BashColor::NONE}#{color_file_with_status(file_name, status)}"
    end
  end

  def color_file_with_status(file_name, status)
    color = status.include?('+') ? BashColor::G : BashColor::R
    "#{color}#{file_name} (#{status})#{BashColor::NONE}"
  end
end
