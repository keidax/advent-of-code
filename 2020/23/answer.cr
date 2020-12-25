# Circular linked list
class LinkedList(T)
  include Enumerable(T)
  property! head : Elem(T)

  def initialize(values : Enumerable(T))
    values.each do |val|
      self << val
    end
  end

  def <<(value : T)
    new_elem = Elem(T).new(value)

    if head?
      head.prev.next = new_elem
      new_elem.prev = head.prev

      head.prev = new_elem
      new_elem.next = head
    else
      self.head = new_elem
      head.next = head
      head.prev = new_elem
    end
  end

  def each_elem(&blk)
    return unless head?

    curr = head
    yield curr
    curr = curr.next

    until curr == head
      yield curr
      curr = curr.next
    end
  end

  def each(&blk)
    each_elem { |elem| yield elem.value }
  end

  def rotate(n = 1)
    if n < 0
      n.abs.times do
        self.head = self.head.prev
      end
    else
      n.times do
        self.head = self.head.next
      end
    end
  end

  def first : T
    head.value
  end

  # Remove the first n elements from this list and return them
  # as a new linked list. Allows passing a list object to reuse.
  def shift(n : Int, new_list = nil)
    new_list ||= LinkedList(T).new([] of T)
    new_list.head = self.head

    end_of_new_list = self.head
    last_elem = self.head.prev

    (n - 1).times do
      end_of_new_list = end_of_new_list.next
    end

    self.head = end_of_new_list.next
    self.head.prev = last_elem
    last_elem.next = self.head

    end_of_new_list.next = new_list.head
    new_list.head.prev = end_of_new_list

    new_list
  end

  def unshift(list : LinkedList(T))
    other_head = list.head
    other_tail = list.head.prev
    old_head = self.head
    old_tail = self.head.prev

    self.head = other_head
    old_tail.next = other_head
    other_head.prev = old_tail

    other_tail.next = old_head
    old_head.prev = other_tail
  end

  def clear
    @head = nil
  end
end

class Elem(T)
  property value : T
  property! next : Elem(T)
  property! prev : Elem(T)

  def initialize(@value)
  end
end

def simulate(cups input : Array(Int32), rounds : Int32) : Array(Int32)
  cups = LinkedList(Int32).new(input)

  elem_listing = Array(Elem(Int32)?).new(size: input.size + 1) { nil }
  cups.each_elem do |e|
    elem_listing[e.value] = e
  end

  removed = LinkedList(Int32).new([] of Int32)

  max_value = input.size

  rounds.times do |i|
    current = cups.head
    cups.rotate(1)

    removed = cups.shift(3, removed)
    r1 = removed.head.value
    r2 = removed.head.next.value
    r3 = removed.head.next.next.value

    destination = current.value - 1
    loop do
      if destination <= 0
        destination = max_value
      end
      if destination == r1 || destination == r2 || destination == r3
        destination -= 1
        next
      end
      break
    end

    destination_elem = elem_listing[destination].not_nil!

    cups.head = destination_elem
    cups.rotate(1)

    cups.unshift(removed)
    removed.clear

    cups.head = current
    cups.rotate(1)
  end

  # return cups with 1 first
  cups.head = elem_listing[1].not_nil!
  cups.to_a
end

input = "394618527".chars.map(&.to_i)

# Part 1
puts simulate(input, rounds: 100)[1..].join ""

# Part 2
output = simulate(input + (10..1_000_000).to_a, rounds: 10_000_000)
puts output[1].to_i64 * output[2].to_i64
