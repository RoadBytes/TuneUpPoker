# frozen_string_literal: true
# Poker compares hands to determine who wins

class Poker
  attr_reader :hands
  def initialize(raw_hands)
    @hands = raw_hands.map { |raw_hand| Hand.new(raw_hand) }
  end

  def best_hand
    best_hand = @hands.sort.last
    @hands.select { |hand| hand.score_vector == best_hand.score_vector }
          .map(&:output_hand)
  end
end

class Hand
  CATEGORY_RANKINGS = {
    straight_flush:  10,
    four_of_a_kind:  9,
    full_house:      8,
    flush:           7,
    straight:        6,
    three_of_a_kind: 5,
    two_pair:        4,
    one_pair:        3,
    high_card:       2
  }.freeze

  attr_accessor :cards, :input

  def <=>(other_hand)
    score_vector <=> other_hand.score_vector
  end

  def initialize(raw_hand)
    @cards = raw_hand.map { |raw_card| Card.new(raw_card) }
    check_for_low_ace
  end

  def check_for_low_ace
    # TODO: Clean up this ACE set up
    if values == [14, 5, 4, 3, 2]
      reset_low_ace
    end
  end

  def reset_low_ace
    cards.map! do |card|
      card.value = 1 if card.value == 14
      card
    end
  end

  # returns array of integers sorted depending on rank and category
  # see calculate_score_vector
  def score_vector
    @score_vector ||= calculate_score_vector
  end

  # [CATEGORY_RANKINGS[category], *sorted_hand]
  # first ranking is compared, then relevant groups in the hand
  # see sorted_hand
  def calculate_score_vector
    return 0 unless cards.size == 5
    ranking = CATEGORY_RANKINGS[category]
    [ranking, *sorted_hand]
  end

  # hand is sorted based on the hands category, ie.
  # one_pair_values = [2, 3, 5, 3, 9]
  # the sorted hand would be [3, 3, 9, 5, 2]
  # pair must be placed before single cards
  def sorted_hand
    send("#{category}_values")
  end

  def category
    @category ||= calculate_category
  end

  def calculate_category
    CATEGORY_RANKINGS.each do |category, _rank|
      return category if send("#{category}?")
    end
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
    values.reverse
  end

  def straight?
    consecutive? && !same_suits?
  end

  def straight_values
    values
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

  def high_card?
    !same_suits? && !consecutive? && no_repeated_values?
  end

  def high_card_values
    values
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
    # returns a array of the numbers in the hand highest to lowest
    cards.map(&:value).sort.reverse
  end

  def no_repeated_values?
    values.uniq.size == values.size
  end

  def suits
    # returns the suit values
    cards.map(&:suit).uniq.sort
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

  def output_hand
    cards.map(&:to_s)
  end
end

# TODO: consider HandCategorizer
#

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
