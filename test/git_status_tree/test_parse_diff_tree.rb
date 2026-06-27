# frozen_string_literal: true

require_relative '../test_helper'

# Unit tests for the diff-tree -z token walk that translates git diff-tree
# output into the porcelain entry strings the node pipeline understands.
class TestParseDiffTree < Minitest::Test
  def setup
    # allocate skips #initialize so no git command runs; we only exercise the
    # private translator directly.
    @tree = GitStatusTree.allocate
  end

  def parse(raw)
    # Backtick output (the real input) is never frozen; dup so the in-place
    # force_encoding doesn't choke on these frozen string literals.
    @tree.send(:parse_diff_tree, raw.dup)
  end

  def test_regular_entries
    raw = "M\0src/main.rb\0A\0README.md\0D\0old.txt\0"
    assert_equal([' M src/main.rb', ' A README.md', ' D old.txt'], parse(raw))
  end

  def test_rename_triplet
    raw = "R100\0old/path.rb\0new/path.rb\0"
    assert_equal([' R old/path.rb -> new/path.rb'], parse(raw))
  end

  def test_copy_triplet
    raw = "C075\0src/a.rb\0src/b.rb\0"
    assert_equal([' C src/a.rb -> src/b.rb'], parse(raw))
  end

  def test_similarity_score_stripped_from_status
    # The Y column carries the bare letter (no score), so Node.status reads it
    # verbatim with no staged "+" suffix.
    assert_equal([' R a -> b'], parse("R087\0a\0b\0"))
  end

  def test_empty_stream
    assert_equal([], parse(''))
  end

  def test_multibyte_paths
    raw = "M\0Ünïcode.md\0"
    result = parse(raw)
    assert_equal([' M Ünïcode.md'], result)
    assert_equal(Encoding::UTF_8, result.first.encoding)
  end

  def test_skips_empty_tokens
    # A leading/trailing NUL produces empty tokens that must be ignored.
    assert_equal([' M a.rb'], parse("M\0a.rb\0"))
  end
end
