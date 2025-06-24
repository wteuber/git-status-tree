# frozen_string_literal: true

require 'test/unit'

class TestVersion < Test::Unit::TestCase
  def test_version_constant_defined
    assert_equal('constant', defined?(GitStatusTree::VERSION))
  end

  def test_version_is_string
    assert(GitStatusTree::VERSION.is_a?(String))
  end

  def test_version_not_empty
    assert(!GitStatusTree::VERSION.empty?)
  end

  def test_version_format
    # Version should match semantic versioning format
    assert_match(/\A\d+\.\d+\.\d+\z/, GitStatusTree::VERSION)
  end

  def test_version_file_exists
    assert(File.exist?(GitStatusTree::VERSION_FILE))
  end

  def test_version_matches_file_content
    version_from_file = File.read(GitStatusTree::VERSION_FILE).strip
    assert_equal(version_from_file, GitStatusTree::VERSION)
  end
end
