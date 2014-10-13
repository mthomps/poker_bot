require_relative 'models/deck'

class HandResult
  include Comparable
  attr_accessor :rank, :primary, :secondary, :kicker_values
  RANKS = {
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

  # The primary and secondary are used to describe the hand and are combined with the kickers to compare for tiebreaking
  def initialize(rank, primary = nil, secondary = nil, kicker_values = [])
    @rank = rank
    @primary = primary
    @secondary = secondary
    @kicker_values = kicker_values
  end

  def <=>(other)
    check_array = [@rank, @primary, @secondary] + @kicker_values
    other_check_array = [other.rank, other.primary, other.secondary] + other.kicker_values
    # the first two elements that are not equal will determine the return value for the whole comparison.
    check_array <=> other_check_array
  end
end

class HandEvaluator
  attr_reader :sorted_cards

  def initialize(cards)
    @sorted_cards = cards.sort!
    @max_straight_value = nil
    @sorted_flush_values = nil
  end

  def eval_seven_card_hand
    counts = value_counts.values
    has_pair = counts.include? 2
    has_triple = counts.include? 3
    if counts.include? 4
      return four_of_a_kind_result
    elsif has_triple && has_pair
      return full_house_result
    end

    if is_flush?
      if is_straight_flush?
        return straight_flush_result
      else
        return flush_result
      end
    elsif is_straight?
      return straight_result
    end

    if has_triple
      return three_of_a_kind_result
    elsif has_pair
      pairs_count = 0
      counts.each do |count| 
        if count == 2
          pairs_count = pairs_count + 1 
        end
      end

      if pairs_count == 2
        return two_pair_result
      else
        return pair_result
      end
    end

    return high_card_result
  end


  private

  # Returns true if the hand contains at least 5 cards of the same suit
  def is_flush?
    suits_of_values = {
      0 => [],
      1 => [],
      2 => [],
      3 => []
    }

    @sorted_cards.each do |card|
      suits_of_values[card.suit] << card.value

      if suits_of_values[card.suit].size >= 5
        @sorted_flush_values = suits_of_values[card.suit].last(5)
      end
    end

    if @sorted_flush_values && @sorted_flush_values.size >= 5
      return true 
    end

    return false
  end
 
  # Returns true if least 5 cards are connectors
  def is_straight?
    return !!@max_straight_value if @max_straight_value
 
    cards = @sorted_cards.clone
    # To check an low ace straight, add a phantom ace with value 1:
    if @sorted_cards.last.value == 14
      ace = @sorted_cards.last
      cards.unshift Card.new(1, ace.suit) 
    end

    max_connected_cards = 1
    connected_card_count = 1
    prev_value = nil
    max_value = nil
    cards.each do |card|
      if prev_value
        if card.value == prev_value + 1
          connected_card_count += 1
          max_connected_cards = connected_card_count if connected_card_count > max_connected_cards
          max_value = card.value
          if connected_card_count >= 5
            @max_straight_value = max_value
          end
        elsif card.value != prev_value
          # dont reset if the prev card has the same value
          connected_card_count = 1
        end
      end

      prev_value = card.value
    end

    return @max_straight_value
  end

  # This is kept separate from #is_straight? for code clarity (at the cost of a bit of duplication)
  def is_straight_flush?
    cards = @sorted_cards.clone
    # To check an low ace straight, add a phantom ace with value 1:
    if @sorted_cards.last.value == 14
      ace = @sorted_cards.last
      cards.unshift Card.new(1, ace.suit) 
    end

    max_connected_cards = 1
    suited_connector_count = 1
    prev_card = nil
    max_value = nil
    cards.each do |card|
      if prev_card
        if card.value == prev_card.value + 1 && card.suit == prev_card.suit
          suited_connector_count += 1
          max_connected_cards = suited_connector_count if suited_connector_count > max_connected_cards
          max_value = card.value
          if suited_connector_count >= 5
            @max_straight_flush_value = max_value
          end
        elsif card.value != prev_card.value
          # dont reset if the prev card has the same value
          suited_connector_count = 1
        end
      end

      prev_card = card
    end

    return @max_straight_flush_value
  end

  def value_counts
    return @multiples if @multiples

    @multiples = {}
    @sorted_cards.each do |card|
      # Aces are always high when hand rank is a multiple (vs straight)
      if @multiples[card.value]
        @multiples[card.value] += 1
      else
        @multiples[card.value] = 1
      end
    end

    @multiples
  end

  ##
  ## Result helpers:
  ##
  def straight_flush_result
    result = HandResult.new HandResult::RANKS[:straight_flush]
    result.primary = @max_straight_flush_value

    result
  end

  def four_of_a_kind_result
    result = HandResult.new HandResult::RANKS[:four_of_a_kind]
    result.primary = value_counts.invert[4]
    result.kicker_values << @sorted_cards.select { |el| el.value != result.primary }.last.value

    result
  end

  def full_house_result
    result = HandResult.new HandResult::RANKS[:full_house]
    result.primary = value_counts.invert[3]
    result.secondary = value_counts.invert[2]

    result
  end

  def flush_result
    result = HandResult.new HandResult::RANKS[:flush]
    result.kicker_values = @sorted_flush_values.reverse

    result
  end

  def straight_result
    result = HandResult.new HandResult::RANKS[:straight]
    result.primary = @max_straight_value

    result
  end

  def three_of_a_kind_result
    result = HandResult.new HandResult::RANKS[:three_of_a_kind]
    result.primary = value_counts.invert[3]
    result.kicker_values = @sorted_cards.select { |el| el.value != result.primary }.last(2).reverse.map(&:value)
  
    result
  end

  def two_pair_result
    result = HandResult.new HandResult::RANKS[:two_pair]
    value_counts.each do |k, v|
      if v == 2
        if result.primary and result.primary < k
          result.secondary = result.primary
          result.primary = k
        elsif result.primary
          result.secondary_rank = k
        else
          result.primary = k
        end
      else
        result.kicker_values = [k] if !result.kicker_values[0] || result.kicker_values[0] < k
      end
    end

    result
  end

  def pair_result
    result = HandResult.new HandResult::RANKS[:pair]
    result.primary = value_counts.invert[2]
    result.kicker_values = @sorted_cards.reverse.select { |card| card.value != result.primary}.first(3).map(&:value)

    result
  end

  def high_card_result
    result = HandResult.new HandResult::RANKS[:high_card]
    used_cards = @sorted_cards.last(5)
    result.primary = used_cards.pop.value
    result.kicker_values += used_cards.map(&:value).reverse
    result
  end
end
