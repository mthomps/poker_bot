require_relative 'card'

class Deck
  def initialize
    reset
  end

  def reset
    generate_cards
    @cards.shuffle
  end

  def draw_card
    @cards.pop
  end

  def pull_card(value=nil, suit=nil)
    index = @cards.find_index do |card|
      value = 14 if value == 1
      val_match = value ? (card.value == value) : true
      suit_match = suit ? (card.suit == suit) : true
      val_match && suit_match
    end

    @cards.delete_at(index) if index
  end


  private

  def generate_cards
    @cards = []
    (2..14).each do |val|
      (0..3).each do |suit|
        @cards << Card.new(val, suit)
      end
    end

    @cards
  end
end
