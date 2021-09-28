Gem.pre_uninstall do |uninstaller|
  bin_dir = uninstaller.spec.bin_dir
  git_remove_alias_tree = File.join(bin_dir, 'git_remove_alias_tree')
  puts `#{git_remove_alias_tree}`
end
