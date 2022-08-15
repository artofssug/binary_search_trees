# frozen_string_literal: true

# Just recreations of the sort and uniq methods to test my knowledge.
module Methods
  # equivalent sort
  def merge_sort(array)
    return array if array.length < 2

    sorted_array = []
    left_array = merge_sort(array[0...array.length / 2])
    right_array = merge_sort(array[array.length / 2..])

    until left_array.empty? || right_array.empty?
      if left_array[0] < right_array[0]
        sorted_array << left_array[0]
        left_array.shift
      else
        sorted_array << right_array[0]
        right_array.shift
      end
    end

    right_array.each { |element| sorted_array << element } if left_array.empty?
    left_array.each { |element| sorted_array << element } if right_array.empty?
    sorted_array
  end

  # equivalent to uniq
  def remove_repeated(array)
    temp_array = []
    array.each { |element| temp_array << element unless temp_array.include?(element) }
    temp_array
  end
end

# Class for each node and its children
class Node
  attr_accessor :left, :right, :data

  def initialize(data, left, right)
    @data = data
    @left = left
    @right = right
  end
end

# Class for the entire binary tree
class Tree
  include Methods

  attr_accessor :root

  def initialize(array)
    @root = build_tree(remove_repeated(merge_sort(array)))
  end

  def build_tree(array, start = 0, final = (array.length - 1), middle = ((start + final) / 2))
    if array.length < 2
      return nil if start > final

      return Node.new(array[middle], nil, nil)
    end

    Node.new(array[middle], build_tree(array[0...middle,]), build_tree(array[middle + 1..]))
  end

  def insert(value, node = @root)
    return @root = Node.new(value, nil, nil) if @root.nil?

    return node.left = Node.new(value, nil, nil) if node.left.nil? && value < node.data

    return node.right = Node.new(value, nil, nil) if node.right.nil? && value > node.data

    if value < node.data
      insert(value, node.left)
    else
      insert(value, node.right)
    end
  end

  def delete(value, node = @root)
    return puts 'Invalid value.' if node.nil?

    if @root.data == value
      father_node = @root
      child_node = @root.right
      return @root = nil if @root.left.nil? && @root.right.nil?

      return @root = @root.right if @root.left.nil?

      return @root = @root.right if @root.right.nil?

    elsif !node.left.nil? && node.left.data == value
      father_node = node.left
      child_node = node.left.right
      return node.left = nil if father_node.left.nil? && father_node.right.nil?

      return node.left = father_node.right if father_node.left.nil?

      return node.left = father_node.left if father_node.right.nil?

    elsif !node.right.nil? && node.right.data == value
      father_node = node.right
      child_node = node.right.right
      return node.right = nil if father_node.left.nil? && father_node.right.nil?

      return node.right = father_node.right if father_node.left.nil?

      return node.right = father_node.left if father_node.right.nil?
    elsif value < node.data
      return delete(value, node.left)
    else
      return delete(value, node.right)
    end

    if child_node.left.nil?
      father_node.right = child_node.right
    else
      father_node = father_node.right
      child_node = child_node.left
      until child_node.left.nil?
        father_node = father_node.left
        child_node = child_node.left
      end
      father_node.left = child_node.right
    end

    return @root.data = child_node.data if @root.data == value

    return node.left.data = child_node.data if node.left.data == value

    return node.right.data = child_node.data if node.right.data == value
  end

  def find(value, node = @root)
    return p node if node.data == value

    if value < node.data
      find(value, node.left)
    else
      find(value, node.right)
    end
  end

  def print(node = @root, prefix = '', is_left = true)
    return puts "nil" if @root.nil?

    print(node.right, "#{prefix}#{is_left ? '│   ' : '    '}", false) if node.right
    puts "#{prefix}#{is_left ? '└── ' : '┌── '}#{node.data}"
    print(node.left, "#{prefix}#{is_left ? '    ' : '│   '}", true) if node.left
  end

  def level_order(queue = [@root], &my_block)
    return if queue.empty?
    my_block.call(queue.first.data)
    [queue.first.left, queue.first.right].each { |element| queue << element unless element.nil? }
    queue.shift
    level_order(queue, &my_block)
  end
end

array = []
35.times { |i| array << i }

tree2 = Tree.new(array)
tree2.print
tree2.delete(24)
tree2.insert(24)
tree2.print
tree2.find(29)

arr = []
tree2.level_order do |node|
  arr << node
end
p arr