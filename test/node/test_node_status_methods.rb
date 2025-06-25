# frozen_string_literal: true

require_relative '../test_helper'

class TestNodeStatusMethods < Test::Unit::TestCase
  def test_modified_status
    node = Node.new('file.txt', nil, 'M ')
    assert(node.modified?)

    node = Node.new('file.txt', nil, ' M')
    assert(node.modified?)

    node = Node.new('file.txt', nil, 'MM')
    assert(node.modified?)

    node = Node.new('file.txt', nil, 'A ')
    assert(!node.modified?)
  end

  def test_added_status
    node = Node.new('file.txt', nil, 'A ')
    assert(node.added?)

    node = Node.new('file.txt', nil, 'AM')
    assert(node.added?)

    node = Node.new('file.txt', nil, 'M ')
    assert(!node.added?)
  end

  def test_deleted_status
    node = Node.new('file.txt', nil, 'D ')
    assert(node.deleted?)

    node = Node.new('file.txt', nil, ' D')
    assert(node.deleted?)

    node = Node.new('file.txt', nil, 'DD')
    assert(node.deleted?)

    node = Node.new('file.txt', nil, 'M ')
    assert(!node.deleted?)
  end

  def test_renamed_status
    node = Node.new('file.txt', nil, 'R ')
    assert(node.renamed?)

    node = Node.new('file.txt', nil, 'RM')
    assert(node.renamed?)

    node = Node.new('file.txt', nil, 'M ')
    assert(!node.renamed?)
  end

  def test_copied_status
    node = Node.new('file.txt', nil, 'C ')
    assert(node.copied?)

    node = Node.new('file.txt', nil, 'CM')
    assert(node.copied?)

    node = Node.new('file.txt', nil, 'M ')
    assert(!node.copied?)
  end

  def test_unmerged_status
    node = Node.new('file.txt', nil, 'U ')
    assert(node.unmerged?)

    node = Node.new('file.txt', nil, 'UU')
    assert(node.unmerged?)

    node = Node.new('file.txt', nil, 'M ')
    assert(!node.unmerged?)
  end

  def test_new_status
    node = Node.new('file.txt', nil, '??')
    assert(node.new?)

    node = Node.new('file.txt', nil, 'M ')
    assert(!node.new?)
  end

  def test_staged_status
    node = Node.new('file.txt', nil, 'M+')
    assert(node.staged?)

    node = Node.new('file.txt', nil, 'A+')
    assert(node.staged?)

    node = Node.new('file.txt', nil, 'D+')
    assert(node.staged?)
  end

  def test_not_staged_status
    node = Node.new('file.txt', nil, 'M')
    assert(!node.staged?)

    node = Node.new('file.txt', nil, '?')
    assert(!node.staged?)
  end
end
