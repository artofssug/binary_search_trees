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
    if value == node.data
      puts "Invalid value."
      return nil
    end

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
    if node.nil?
      puts 'Invalid value.'
      return nil
    end

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
    if node.nil?
      puts 'Invalid value.'
      return nil
    end

    return node if node.data == value

    if value < node.data
      find(value, node.left)
    else
      find(value, node.right)
    end
  end

  def level_order(queue = [@root], arr = [], &my_block)
    return arr if queue.empty?

    my_block.call(queue.first.data) if block_given?
    [queue.first.left, queue.first.right].each { |element| queue << element unless element.nil? }
    arr << queue.first.data unless block_given?
    queue.shift
    return level_order(queue, &my_block) if block_given?

    level_order(queue, arr)
  end

  def preorder(father = @root, arr = [], &my_block)
    left = father.left
    right = father.right
    if block_given?
      yield father.data if father.data == @root.data
      yield left.data unless left.nil?
    elsif father.data == @root.data
      [father.data, left.data].each { |element| arr << element unless element.nil? }
    else
      arr << left.data unless left.nil?
    end
    preorder(left, arr, &my_block) unless left.nil?
    if block_given?
      yield right.data unless right.nil?
    else
      arr << right.data unless right.nil?
    end
    preorder(right, arr, &my_block) unless right.nil?
    arr
  end

  def inorder(father = @root, arr = [], &my_block)
    inorder(father.left, arr, &my_block) unless father.left.nil?
    yield father.data if block_given?
    arr << father.data
    inorder(father.right, arr, &my_block) unless father.right.nil?
    arr
  end

  def postorder(father = @root, arr = [], &my_block)
    postorder(father.left, arr, &my_block) unless father.left.nil?
    postorder(father.right, arr, &my_block) unless father.right.nil?

    if block_given?
      yield father.data
    else
      arr << father.data
    end
    arr
  end

  def height(node, height = 0, child = nil)
    if node.nil?
      puts 'Invalid value.'
      return nil
    end
    left_height = 0
    right_height = 0

    left_height += height(node.left, height + 1) unless node.left.nil?
    right_height += height(node.right, height + 1) unless node.right.nil?

    return height if left_height.zero? && right_height.zero?

    left_height <= right_height ? right_height : left_height
  end

  def depth(node, depth = 0, root = @root)
    return depth if node.data == root.data
    node.data < root.data ? depth(node, depth + 1, root.left) : depth(node, depth + 1, root.right)
  end

  def balanced?(node = @root, height = 0)
    left_height = 0
    right_height = 0
    left_height += balanced?(node.left, height + 1) unless node.left.nil?
    right_height += balanced?(node.right, height + 1) unless node.right.nil?

    if node.data == @root.data
      return true if left_height == right_height

      return true if left_height - right_height == 1 || right_height - left_height == 1

      return false
    end

    return height if left_height.zero? && right_height.zero?

    left_height <= right_height ? right_height : left_height
  end

  def rebalance
    initialize(inorder)
  end

  def print(node = @root, prefix = '', is_left = true)
    return puts nil if @root.nil?

    print(node.right, "#{prefix}#{is_left ? '│   ' : '    '}", false) if node.right
    puts "#{prefix}#{is_left ? '└── ' : '┌── '}#{node.data}"
    print(node.left, "#{prefix}#{is_left ? '    ' : '│   '}", true) if node.left
  end
end

array = (Array.new(15) { rand(1..100) })

tree = Tree.new(array)

tree.print
puts tree.balanced?

p tree.level_order
p tree.preorder
p tree.inorder
p tree.postorder

tree.insert(100)
tree.insert(105)
tree.insert(110)
tree.insert(115)
tree.print
puts tree.balanced?

tree.rebalance
tree.print
p tree.level_order
p tree.preorder
p tree.inorder
p tree.postorder
puts tree.balanced?