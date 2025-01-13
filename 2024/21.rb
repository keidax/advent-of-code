require_relative "aoc"

# Represents a sequence of keys typed on a keypad. Day 21 is set up so that
# every sequence can be broken down into sub-sequences ending in "A". The
# important insight here is that our final answer only requires the total length
# of the sequence. So we can break down a sequence like ">A>A>A<A<A" into a map
# of sub-sequences and their counts: {">A": 3, "<A": 2}.
class KeypadSequence
  NUMERIC_KEYPAD = [
    ["7", "8", "9"],
    ["4", "5", "6"],
    ["1", "2", "3"],
    [nil, "0", "A"]
  ]

  DIRECTIONAL_KEYPAD = [
    [nil, "^", "A"],
    ["<", "v", ">"]
  ]

  # Create a new KeypadSequence.
  #
  # If the argument is a string, it is treated as a numeric keypad sequence
  # ending in "A".
  #
  # Otherwise, the argument should be a hash, mapping sub-sequences to counts.
  # @param numeric_code_or_hash [String, Hash<String, Integer>]
  def initialize(numeric_code_or_hash)
    @sequence_count = if numeric_code_or_hash.is_a?(Hash)
      numeric_code_or_hash
    else
      sequence_for_numeric_keypad(numeric_code_or_hash)
    end
  end

  attr_reader :sequence_count
  protected :sequence_count

  # Repeat a sequence a certain number of times.
  # @param multiplier [Integer] the number of repetitions
  # @return [self] a new KeypadSequence that is `multiplier` times longer.
  def *(multiplier) # standard:disable Naming/BinaryOperatorParameterName
    self.class.new(@sequence_count.transform_values { |v| v * multiplier })
  end

  # Add another KeypadSequence to this one.
  # @param other [self] another sequence
  # @return [self] a KeypadSequence representing the concatenation of this
  #   sequence and `other`
  def +(other)
    new_counts = @sequence_count.merge(other.sequence_count) do |seq, count1, count2|
      count1 + count2
    end
    self.class.new(new_counts)
  end

  # Get the total length of this sequence
  # @return [Integer] total length of this sequence in characters
  def size
    @sequence_count.sum { |seq, count| seq.size * count }
  end

  # Return a hash representing a sub-sequence that produces this numeric
  # sequence on a directional keypad.
  # @param numbers [String] the numeric keypad sequence
  # @return [Hash<String, Integer>] a hash representing the expanded sequence
  #   with minimal length
  def sequence_for_numeric_keypad(numbers)
    # Start hovering over "A"
    current_row, current_col = 3, 2
    empty_row, empty_col = 3, 0

    sequence_combos = []

    numbers.chars.each do |key|
      target_row, target_col = self.class.find_in_keypad(key, NUMERIC_KEYPAD)

      horizontal_segment = if current_col < target_col
        ">" * (target_col - current_col)
      else
        "<" * (current_col - target_col)
      end

      vertical_segment = if current_row < target_row
        "v" * (target_row - current_row)
      else
        "^" * (current_row - target_row)
      end

      if current_row == target_row
        sequence_combos << (horizontal_segment + "A")
      elsif current_col == target_col
        sequence_combos << (vertical_segment + "A")
      elsif current_row == empty_row && target_col == empty_col
        # We need to move up and left. Make sure we move up first.
        seq = "^" * (current_row - target_row)
        seq += "<" * (current_col - target_col)
        seq += "A"
        sequence_combos << seq
      elsif current_col == empty_col && target_row == empty_row
        # We need to move down and right. Make sure we move right first.
        seq = ">" * (target_col - current_col)
        seq += "v" * (target_row - current_row)
        seq += "A"
        sequence_combos << seq
      else
        option_a = horizontal_segment + vertical_segment + "A"
        option_b = vertical_segment + horizontal_segment + "A"

        # consider moving either direction first
        shortest = self.class.choose_shortest_sequence(option_a, option_b)
        sequence_combos << shortest
      end

      current_row, current_col = target_row, target_col
    end

    sequence_combos.tally
  end

  # Cache the shortest expanded version of a subsequence
  # @return [Hash{Array[String] => String,Symbol}]
  @@shortest_seq_cache = {}

  # Generate possible translations for a sequence.
  #
  # Our goal is generally to find the shortest translation. Sometimes, several
  # rounds of translation are required before we know which sequence expands
  # into a shorter form. If we know the shortest translation for the current
  # sequence (because it can be immediately measured, or we've expanded and
  # cached the best outcome) that option will be returned. Otherwise, an array
  # of several options will be returned.
  # @return [Array<KeypadSequence>] one or more translations of this sequence.
  #   If multiple translations are returned, they will all be valid, but they
  #   may eventually be shorter or longer after repeated translation.
  def possible_translations
    known_sequence = self.class.new({})
    options = []

    @sequence_count.each do |seq, count|
      translated_seqs = self.class.possible_sequences_for_directional_keypad(seq)
        .map { |seq| seq * count }

      if translated_seqs.size == 1
        known_sequence += translated_seqs[0]
      else
        options << translated_seqs
      end
    end

    if options.any?
      possible_sequences = [known_sequence]

      options.each do |(option_a, option_b)|
        seqs_with_a = possible_sequences.map { _1 + option_a }
        seqs_with_b = possible_sequences.map { _1 + option_b }

        possible_sequences = seqs_with_a + seqs_with_b
      end

      possible_sequences
    else
      [known_sequence]
    end
  end

  # Return a new sequence, representing the inputs to produce this sequence on a
  # directional keypad.
  # @return [self] an expanded sequence producing the current sequence with
  #   minimal length
  def translate
    new_sequence = self.class.new({})
    @sequence_count.each do |seq, count|
      translated_seqs = self.class.possible_sequences_for_directional_keypad(seq)
      if translated_seqs.size != 1
        raise "expected direct translation"
      end

      new_sequence += translated_seqs[0] * count
    end

    new_sequence
  end

  # Cache the translation of sub-sequences
  # @return [Hash<String, KeypadSequence>]
  @@translation_cache = {}

  class << self
    # Given two sub-sequences, return the one that generates the shortest
    # sequence after translation.
    # @param a [String] a sub-sequence to compare
    # @param b [String] another sub-sequence to compare
    # @return [Symbol] if a comparison between a and b is currently underway,
    #   the :pending symbol is returned
    # @return [String] the sub-sequence that translates into the shortest
    #   sequence
    def choose_shortest_sequence(a, b)
      cache_key = [a, b].sort

      if @@shortest_seq_cache.key?(cache_key)
        return @@shortest_seq_cache[cache_key]
      end

      if a.size > b.size
        @@shortest_seq_cache[cache_key] = a
        return a
      elsif b.size > a.size
        @@shortest_seq_cache[cache_key] = b
        return b
      end

      # It's possible that a sub-sequence translates into a sequence containing
      # itself. And if there are multiple options for the shortest translation,
      # this method may be called with the same arguments recursively. To
      # prevent infinite recursion, we mark the current shortest comparison as
      # pending.
      @@shortest_seq_cache[cache_key] = :pending

      a_seqs = [new({a => 1})]
      b_seqs = [new({b => 1})]
      shorter = nil

      # In practice, 5 rounds of translation is always enough to find a shorter
      # sequence
      5.times do
        a_seqs = a_seqs.flat_map(&:possible_translations)
        b_seqs = b_seqs.flat_map(&:possible_translations)

        a_min = a_seqs.map(&:size).min
        b_min = b_seqs.map(&:size).min

        if a_min < b_min
          shorter = a
          break
        elsif b_min < a_min
          shorter = b
          break
        end
      end

      if shorter.nil?
        raise "couldn't find a shorter sequence between #{a.inspect} and #{b.inspect}"
      end

      @@shortest_seq_cache[cache_key] = shorter
      shorter
    end

    # Translate a sub-sequence into an expanded sequence on a directional
    # keypad. If it's possible to find one shortest translation, only that
    # sequence will be returned. If that is not possible (i.e. we are trying to
    # translate a sub-sequence that is part of a :pending comparison) multiple
    # sequences will be returned.
    # @param arrows [String] one sequence ending in A
    # @return [Array<KeypadSequence>] one or more translated sequences
    def possible_sequences_for_directional_keypad(arrows)
      if @@translation_cache.key?(arrows)
        return [@@translation_cache[arrows]]
      end

      # Start hovering over "A"
      current_row, current_col = 0, 2
      empty_row, empty_col = 0, 0

      known_sequence = []
      options = []

      arrows.chars.each do |key|
        target_row, target_col = find_in_keypad(key, DIRECTIONAL_KEYPAD)

        horizontal_segment = if current_col < target_col
          ">" * (target_col - current_col)
        else
          "<" * (current_col - target_col)
        end

        vertical_segment = if current_row < target_row
          "v" * (target_row - current_row)
        else
          "^" * (current_row - target_row)
        end

        if current_row == target_row
          known_sequence << (horizontal_segment + "A")
        elsif current_col == target_col
          known_sequence << (vertical_segment + "A")
        elsif current_row == empty_row && target_col == empty_col
          begin
            # We need to move down and left. Make sure we move down first.
            seq = "v" * (target_row - current_row)
            seq += "<" * (current_col - target_col)
            seq += "A"
            known_sequence << seq
          end
        elsif current_col == empty_col && target_row == empty_row
          # We need to move up and right. Make sure we move right first.
          seq = ">" * (target_col - current_col)
          seq += "^" * (current_row - target_row)
          seq += "A"
          known_sequence << seq
        else
          option_a = horizontal_segment + vertical_segment + "A"
          option_b = vertical_segment + horizontal_segment + "A"

          # consider moving either direction first
          shortest = choose_shortest_sequence(option_a, option_b)
          if shortest == :pending
            options << [option_a, option_b]
          else
            known_sequence << shortest
          end
        end

        current_row, current_col = target_row, target_col
      end

      if options.any?
        possible_sequences = [known_sequence]

        options.each do |(option_a, option_b)|
          seqs_with_a = possible_sequences
          seqs_with_b = possible_sequences.map(&:dup)

          seqs_with_a.each { _1 << option_a }
          seqs_with_b.each { _1 << option_b }

          possible_sequences = seqs_with_a + seqs_with_b
        end

        possible_sequences.map { new(_1.tally) }
      else
        translated = new(known_sequence.tally)
        @@translation_cache[arrows] = translated
        [translated]
      end
    end

    # Find the location of a target character in a keypad
    # @param target [String] the target character
    # @param keypad [Array<Array<String>>] a 2-d array of characters
    # @return [Array(Integer, Integer)] the row and column of target in keypad
    def find_in_keypad(target, keypad)
      keypad.each_with_index do |line, row|
        line.each_with_index do |key, col|
          return [row, col] if key == target
        end
      end

      raise "could not find #{target.inspect}"
    end
  end
end

input = AOC.day(21)
codes = input.lines(chomp: true)

AOC.part1 do
  codes.sum do |code|
    seq = KeypadSequence.new(code)

    2.times do
      seq = seq.translate
    end

    code_number = code[0..-2].to_i
    code_number * seq.size
  end
end

AOC.part2 do
  codes.sum do |code|
    seq = KeypadSequence.new(code)

    25.times do
      seq = seq.translate
    end

    code_number = code[0..-2].to_i
    code_number * seq.size
  end
end
