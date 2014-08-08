require_relative '../models/card'

describe Card do
  describe '#initialize' do
    it 'creates a card given a value and suit' do
      card = Card.new 12, 3
      expect(card.value).to eq 12
      expect(card.suit).to eq 3
    end

    it 'throws an argument error when given bad arguments' do
      expect{Card.new(:horse, 'Charles Babbage')}.to raise_error(ArgumentError)
      expect{Card.new}.to raise_error(ArgumentError)
      expect{Card.new 3, nil}.to raise_error(ArgumentError)
    end
  end
end
