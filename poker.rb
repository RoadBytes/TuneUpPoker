# frozen_string_literal: true
# Poker compares hands to determine who wins

class Poker
  attr_reader :hands
  def initialize(hand_array)
    @hands = array_of_hands(hand_array)
  end

  def array_of_hands(hand_array)
    temp_hands = []
    hand_array.each do |hand|
      temp_hands << Hand.new(hand)
    end
    temp_hands
  end

  def best_ranked_hands
    best_rank = hands.map(&:ranking).max
    hands.select { |hand| hand.ranking == best_rank }
  end

  def best_hand
    # TODO: Your mission, should you choose to accept it,
    # refactor `Poker#best_hand` in a way that would be more sensible.
    best_hands = best_ranked_hands
    highest_card_value = 0
    best_hands.each do |hand|
      high_hand_value = hand.max_card_value
      if high_hand_value > highest_card_value
        highest_card_value = high_hand_value
      end
    end
    best_hands.select { |hand| hand.max_card_value == highest_card_value }
              .map(&:input)
  end
end

class Hand
  attr_accessor :cards, :input

  def initialize(hand_array)
    @input = hand_array
    @cards = cards_array(hand_array)
    check_for_low_ace
  end

  def cards_array(hand_array)
    temp_cards_array = []
    hand_array.each do |card|
      temp_cards_array << Card.new(card)
    end
    temp_cards_array.sort_by { |card| "#{card.value}#{card.suit}" }
  end

  def check_for_low_ace
    if values == [2, 3, 4, 5, 14]
      reset_low_ace
    end
  end

  def reset_low_ace
    cards.map! do |card|
      card.value = 1 if card.value == 14
      card
    end
  end

  def ranking
    return 0 unless cards.size == 5
    # returns a array value of it's ranking
    # and an array of values to compare
    return [10, straight_flush_values] if straight_flush?
    return [9, four_of_a_kind_values]  if four_of_a_kind?
    return [8, full_house_values]      if full_house?
    return [7, flush_values]           if flush?
    return [6, straight_values]        if straight?
    return [5, three_of_a_kind_values] if triple?
    return [4, two_pair_values]        if two_pair?
    return [3, one_pair_values]        if one_pair?

    [2, values.reverse]
  end

  def straight_flush?
    same_suits? && consecutive?
  end

  def straight_flush_values
    values.reverse
  end

  def four_of_a_kind?
    value_frequency_hash.any? { |_card_number, count| count == 4 }
  end

  def four_of_a_kind_values
    four_of_a_kind_value = cards_repeated_n_times(4)
    single_card_value    = cards_repeated_n_times(1)
    [four_of_a_kind_value, single_card_value].flatten
  end

  def full_house?
    triple? && double?
  end

  def full_house_values
    triple_value = cards_repeated_n_times(3)
    double_value = cards_repeated_n_times(2)
    [triple_value, double_value].flatten
  end

  def flush?
    !consecutive? && same_suits?
  end

  def flush_values
    [max_card_value]
  end

  def straight?
    consecutive? && !same_suits?
  end

  def straight_values
    [max_card_value]
  end

  def same_suits?
    suits.size == 1
  end

  def three_of_a_kind?
    triple? && !double?
  end

  def three_of_a_kind_values
    triple_value = cards_repeated_n_times(3)
    singles      = cards_repeated_n_times(1)
    [triple_value, singles].flatten
  end

  def two_pair?
    value_frequency_hash.select { |_card_number, count| count == 2 }.size == 2
  end

  def two_pair_values
    doubles = cards_repeated_n_times(2)
    single  = cards_repeated_n_times(1)
    [doubles, single].flatten
  end

  def one_pair?
    value_frequency_hash.select { |_card_number, count| count == 2 }.size == 1
  end

  def one_pair_values
    double  = cards_repeated_n_times(2)
    singles = cards_repeated_n_times(1)
    [double, singles].flatten
  end

  def triple?
    value_frequency_hash.any? { |_card_number, count| count == 3 }
  end

  def double?
    value_frequency_hash.any? { |_card_number, count| count == 2 }
  end

  def consecutive?
    values_max    = values.max
    values_min    = values.min
    (values_min..values_max).to_a == values.sort
  end

  def values
    # returns a array of the numbers in the hand
    cards.map(&:value).sort
  end

  def suits
    # returns the suit values
    cards.map(&:suit).uniq
  end

  def value_frequency_hash
    frequency_hash = Hash.new(0)
    values.each { |card_number| frequency_hash[card_number] += 1 }
    frequency_hash
  end

  def cards_repeated_n_times(repeats)
    value_frequency_hash.select do |_card_number, count|
      count == repeats
    end.keys.sort.reverse
  end

  def max_card_value
    values.last
  end
end

class Card
  attr_accessor :value
  attr_reader   :character, :suit

  def initialize(card_string)
    # ie. '1H', '9C', 'TD', 'JS'
    @character, @suit = card_string.split('')
    @value = convert_value(character)
  end

  def convert_value(value)
    return 14 if value == 'A'
    return 13 if value == 'K'
    return 12 if value == 'Q'
    return 11 if value == 'J'
    return 10 if value == 'T'
    value.to_i
  end

  def to_s
    "#{character}#{suit}"
  end
end
