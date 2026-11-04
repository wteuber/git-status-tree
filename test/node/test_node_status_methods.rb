# frozen_string_literal: true

require_relative '../test_helper'

class TestNodeStatusMethods < Minitest::Test
  def test_modified_status
    node = Node.new('file.txt', nil, 'M ')

    assert_predicate(node, :modified?)

    node = Node.new('file.txt', nil, ' M')

    assert_predicate(node, :modified?)

    node = Node.new('file.txt', nil, 'MM')

    assert_predicate(node, :modified?)

    node = Node.new('file.txt', nil, 'A ')

    refute_predicate(node, :modified?)
  end

  def test_added_status
    node = Node.new('file.txt', nil, 'A ')

    assert_predicate(node, :added?)

    node = Node.new('file.txt', nil, 'AM')

    assert_predicate(node, :added?)

    node = Node.new('file.txt', nil, 'M ')

    refute_predicate(node, :added?)
  end

  def test_deleted_status
    node = Node.new('file.txt', nil, 'D ')

    assert_predicate(node, :deleted?)

    node = Node.new('file.txt', nil, ' D')

    assert_predicate(node, :deleted?)

    node = Node.new('file.txt', nil, 'DD')

    assert_predicate(node, :deleted?)

    node = Node.new('file.txt', nil, 'M ')

    refute_predicate(node, :deleted?)
  end

  def test_renamed_status
    node = Node.new('file.txt', nil, 'R ')

    assert_predicate(node, :renamed?)

    node = Node.new('file.txt', nil, 'RM')

    assert_predicate(node, :renamed?)

    node = Node.new('file.txt', nil, 'M ')

    refute_predicate(node, :renamed?)
  end

  def test_copied_status
    node = Node.new('file.txt', nil, 'C ')

    assert_predicate(node, :copied?)

    node = Node.new('file.txt', nil, 'CM')

    assert_predicate(node, :copied?)

    node = Node.new('file.txt', nil, 'M ')

    refute_predicate(node, :copied?)
  end

  def test_unmerged_status
    node = Node.new('file.txt', nil, 'U ')

    assert_predicate(node, :unmerged?)

    node = Node.new('file.txt', nil, 'UU')

    assert_predicate(node, :unmerged?)

    node = Node.new('file.txt', nil, 'M ')

    refute_predicate(node, :unmerged?)
  end

  def test_new_status
    node = Node.new('file.txt', nil, '??')

    assert_predicate(node, :new?)

    node = Node.new('file.txt', nil, 'M ')

    refute_predicate(node, :new?)
  end

  def test_staged_status
    node = Node.new('file.txt', nil, 'M+')

    assert_predicate(node, :staged?)

    node = Node.new('file.txt', nil, 'A+')

    assert_predicate(node, :staged?)

    node = Node.new('file.txt', nil, 'D+')

    assert_predicate(node, :staged?)
  end

  def test_not_staged_status
    node = Node.new('file.txt', nil, 'M')

    refute_predicate(node, :staged?)

    node = Node.new('file.txt', nil, '?')

    refute_predicate(node, :staged?)
  end
end
