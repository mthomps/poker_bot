require_relative '../hand_evaluator'

describe HandEvaluator do
  let(:deck) { Deck.new }
  let(:hand) { [] }

  describe '#initialize' do
    it 'sorts the given hand' do
      3.times { hand << deck.draw_card }
      hand << deck.pull_card(13)
      hand << deck.pull_card(1)

      hand_eval = HandEvaluator.new hand
      expect(hand_eval.sorted_cards).to eq hand_eval.sorted_cards.sort
    end
  end

  describe '#eval_five_card_hand' do
    it 'detects straight flush' do
      5.times { |i| hand << deck.pull_card(i + 1, 0) }

      hand_eval = HandEvaluator.new hand
      expect(hand_eval.eval_five_card_hand).to eq HandEvaluator::HAND_POSSIBILITIES[:straight_flush]
    end

    it 'detects 4-of-a-kind' do
      4.times { hand << deck.pull_card(13) }
      hand << deck.draw_card

      hand_eval = HandEvaluator.new hand
      expect(hand_eval.eval_five_card_hand).to eq HandEvaluator::HAND_POSSIBILITIES[:four_of_a_kind]
    end

    it 'detects full house' do
      3.times { hand << deck.pull_card(13) }
      2.times { hand << deck.pull_card(7) }

      hand_eval = HandEvaluator.new hand
      expect(hand_eval.eval_five_card_hand).to eq HandEvaluator::HAND_POSSIBILITIES[:full_house]
    end

    it 'detects flush' do
      5.times { |i| hand << deck.pull_card((i * 2 + 1), 2) }

      hand_eval = HandEvaluator.new hand
      expect(hand_eval.eval_five_card_hand).to eq HandEvaluator::HAND_POSSIBILITIES[:flush]
    end

    it 'detects straight' do
      5.times { |i| hand << deck.pull_card(i + 1, i % 3) }

      hand_eval = HandEvaluator.new hand
      expect(hand_eval.eval_five_card_hand).to eq HandEvaluator::HAND_POSSIBILITIES[:straight]
    end

    it 'detects 3-of-a-kind' do
      3.times { hand << deck.pull_card(10) }
      hand << deck.pull_card(2, 0)
      hand << deck.pull_card(12, 0)

      hand_eval = HandEvaluator.new hand
      expect(hand_eval.eval_five_card_hand).to eq HandEvaluator::HAND_POSSIBILITIES[:three_of_a_kind]
    end

    it 'detects two_pair' do
      2.times { hand << deck.pull_card(2) }
      2.times { hand << deck.pull_card(1) }
      hand << deck.pull_card(8)

      hand_eval = HandEvaluator.new hand
      expect(hand_eval.eval_five_card_hand).to eq HandEvaluator::HAND_POSSIBILITIES[:two_pair]
    end

    it 'detects pair' do
      2.times { hand << deck.pull_card(7) }
      3.times { |i| hand << deck.pull_card(i + 1) }

      hand_eval = HandEvaluator.new hand
      expect(hand_eval.eval_five_card_hand).to eq HandEvaluator::HAND_POSSIBILITIES[:pair]
    end

    it 'detects high_card' do
      5.times { |i| hand << deck.pull_card((i * 2 + 1), i % 3) }

      hand_eval = HandEvaluator.new hand
      expect(hand_eval.eval_five_card_hand).to eq HandEvaluator::HAND_POSSIBILITIES[:high_card]
    end
  end
end
