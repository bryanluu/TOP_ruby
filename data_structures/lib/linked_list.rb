# frozen_string_literal: true

# Node of a Linked List
class Node
  attr_accessor :value, :next

  def initialize
    @value = nil
    @next = nil
  end
end

# Class representing a Linked List
class LinkedList
  attr_reader :head

  def initialize
    @head = nil
  end

  # add node with value to end of list and return the new head
  def append(value)
    node = Node.new
    node.value = value
    if head.nil?
      @head = node
    else
      curr = head
      curr = curr.next until curr.next.nil?
      curr.next = node
    end
    head
  end

  # add node with value to start of list
  def prepend(value)
    node = Node.new
    node.value = value
    node.next = head
    @head = node
  end

  # get size of Linked List
  def size
    sz = 0
    curr = head
    until curr.nil?
      curr = curr.next
      sz += 1
    end
    sz
  end

  # get last element of Linked List
  def tail
    curr = head
    curr = curr.next until curr.next.nil?
    curr
  end

  # get element at zero-based index
  def at(index)
    curr = head
    index.downto(1) do |_|
      break if curr.nil?

      curr = curr.next
    end
    curr
  end

  # removes and returns the last element in the list
  def pop
    return nil if head.nil?

    curr = head
    if curr.next.nil?
      @head = nil
      return curr
    end
    curr = curr.next until curr.next.next.nil?
    last = curr.next
    curr.next = nil
    last.value
  end

  # returns whether the value is inside the list
  def contains?(value)
    return false if head.nil?

    curr = head
    until curr.nil?
      return true if curr.value == value

      curr = curr.next
    end
    false
  end

  # returns the zero-based index of the value in list, or nil if not in list
  def find(value)
    return nil if head.nil?

    index = 0
    curr = head
    until curr.nil?
      return index if curr.value == value

      index += 1
      curr = curr.next
    end
    nil
  end

  # insert at zero-based index into list, returning the new head
  def insert_at(value, index)
    node = Node.new
    node.value = value
    curr = head
    return (@head = node) if index.zero?

    index.downto(2) do |_|
      break if curr.next.nil?

      curr = curr.next
    end
    node.next = curr.next
    curr.next = node
    head
  end

  # remove node at zero-based index into list, returning the value
  def remove_at(index)
    return nil if head.nil?

    if index.zero?
      node = head
      @head = head.next
      return node.value
    end

    curr = head
    index.downto(2) do |_|
      break if curr.next.nil?

      curr = curr.next
    end
    node = curr.next
    node.nil? ? (return nil) : (curr.next = node.next)
    node.value
  end

  # string representation of list, (value) -> (value) -> nil etc
  def to_s
    nil.to_s if head.nil?

    curr = head
    str = String.new
    until curr.nil?
      str << '( ' << curr.value.to_s << ' )' << ' -> '
      curr = curr.next
    end
    str << 'nil'
    str
  end
end
