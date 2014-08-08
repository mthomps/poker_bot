require_relative 'models/deck'

class HandEvaluator
  attr_reader :sorted_cards

  HAND_POSSIBILITIES = {
    straight_flush: 8,
    four_of_a_kind: 7,
    full_house: 6,
    flush: 5,
    straight: 4,
    three_of_a_kind: 3,
    two_pair: 2,
    pair: 1,
    high_card: 0
  }

  def initialize(cards)
    @sorted_cards = cards.sort!
  end

  def eval_five_card_hand
    counts = value_counts_hash.values
    has_pair = counts.include? 2
    has_triple = counts.include? 3
    if counts.include? 4
      return HAND_POSSIBILITIES[:four_of_a_kind]
    elsif has_triple and has_pair
      return HAND_POSSIBILITIES[:full_house]
    end

    is_straight = is_straight?
    if is_flush?
      if is_straight
        return HAND_POSSIBILITIES[:straight_flush]
      else
        return HAND_POSSIBILITIES[:flush]
      end
    elsif is_straight
      return HAND_POSSIBILITIES[:straight]
    end

    if has_triple
      return HAND_POSSIBILITIES[:three_of_a_kind]
    elsif has_pair
      pairs_count = 0
      counts.each do |count| 
        if count == 2
          pairs_count = pairs_count + 1 
        end
      end

      if pairs_count == 2
        return HAND_POSSIBILITIES[:two_pair]
      else
        return HAND_POSSIBILITIES[:pair]
      end
    end

    return HAND_POSSIBILITIES[:high_card]
  end


  private

  def is_flush?
    suit_hash = {
      0 => 0,
      1 => 0,
      2 => 0,
      3 => 0
    }
    @sorted_cards.each do |card|
      suit_hash[card.suit] += 1
      return true if suit_hash[card.suit] == 5
    end

    false
  end

  def is_straight?
    cards = @sorted_cards.clone
    # To make it easier to deal with aces, add a phantom ace with value 14:
    if @sorted_cards.first.value == 1
      ace = @sorted_cards.first 
      cards << Card.new(14, ace.suit) 
    end

    max_connected_cards = 1
    connected_card_count = 1
    prev_value = nil
    cards.each do |card|
      if prev_value
        if card.value == prev_value + 1
          connected_card_count += 1
          max_connected_cards = connected_card_count if connected_card_count > max_connected_cards
        else
          connected_card_count = 1
        end
      end

      prev_value = card.value
    end

    if @sorted_cards.count >= 5
      return max_connected_cards >= 5
    else
      return max_connected_cards >= @sorted_cards.count
    end
  end

  # TEST:
  # 1 2 5 6 7 8 9
  # 1 8 9 10 11 12 13 

  def value_counts_hash
    multiples = {}
    @sorted_cards.each do |card|
      if multiples[card.value]
        multiples[card.value] += 1
      else
        multiples[card.value] = 1
      end
    end

    multiples
  end
end
