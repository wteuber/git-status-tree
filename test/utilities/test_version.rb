# frozen_string_literal: true

require_relative '../test_helper'

class TestVersion < Minitest::Test
  def test_version_constant_defined
    assert_equal('constant', defined?(GitStatusTree::VERSION))
  end

  def test_version_is_string
    assert_kind_of(String, GitStatusTree::VERSION)
  end

  def test_version_not_empty
    refute_empty(GitStatusTree::VERSION)
  end

  def test_version_format
    assert_match(/\A\d+\.\d+\.\d+\z/, GitStatusTree::VERSION)
  end

  def test_version_file_exists
    assert_path_exists(GitStatusTree::VERSION_FILE)
  end

  def test_version_matches_file_content
    version_from_file = File.read(GitStatusTree::VERSION_FILE).strip

    assert_equal(version_from_file, GitStatusTree::VERSION)
  end
end
