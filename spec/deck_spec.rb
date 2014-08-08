require_relative '../models/deck'

# So we can peek inside the deck for testing purposes:
class Deck
  attr_reader :cards
end

describe Deck do
  subject(:deck) { Deck.new }

  describe '#initialize' do
    it 'creates a shuffled deck of cards' do
      expect(deck.cards.size).to eq 52
    end
  end

  describe '#draw_card' do
    it 'removes and returns the top (last) card in the deck' do
      last_card = deck.cards.last
      drawn_card = deck.draw_card
      expect(last_card).to eq drawn_card
      expect(deck.cards.size).to eq 51
    end

    it 'returns nil if deck is empty' do
      52.times { deck.draw_card }
      drawn_card = deck.draw_card
      expect(drawn_card).to eq nil
      expect(deck.cards.size).to eq 0
    end
  end

  describe '#pull_card' do
    it 'removes the first card if not given any arguments' do
      first_card = deck.cards.first
      pulled_card = deck.pull_card
      expect(first_card).to eq pulled_card
      expect(deck.cards.size).to eq 51
    end

    it 'removes the first card of a given value if only given a value argument' do
      pulled_card = deck.pull_card 10
      expect(pulled_card.value).to eq 10
      expect(deck.cards.size).to eq 51
    end

    it 'removes the first card of a given suit if only given a suit argument' do
      pulled_card = deck.pull_card nil, 2
      expect(pulled_card.suit).to eq 2
      expect(deck.cards.size).to eq 51
    end

    it 'removes the first card of a given suit and value if given 2 arguments' do
      pulled_card = deck.pull_card 13, 1
      expect(pulled_card.value).to eq 13
      expect(pulled_card.suit).to eq 1
      expect(deck.cards.size).to eq 51
    end

    it 'removes no cards and returns nil if not found' do
      pulled_card = deck.pull_card 20, 1
      expect(pulled_card).to eq nil
      expect(deck.cards.size).to eq 52
    end

    it 'returns nil if deck is empty' do
      52.times { deck.draw_card }
      pulled_card = deck.pull_card
      expect(pulled_card).to eq nil
      expect(deck.cards.size).to eq 0
    end
  end
end
