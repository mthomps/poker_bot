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

  describe '#eval_seven_card_hand' do
    it 'detects straight flush' do
      5.times { |i| hand << deck.pull_card(i + 1, 0) }
      2.times { |i| hand << deck.pull_card(12) }
      hand_eval = HandEvaluator.new hand
      result = hand_eval.eval_seven_card_hand

      expect(result.rank).to eq HandResult::RANKS[:straight_flush]
      expect(result.primary).to eq 5
      expect(result.secondary).to eq nil
      expect(result.kicker_values.size).to eq 0
    end

    it 'detects ace-high straight flush' do
      7.times { |i| hand << deck.pull_card(i + 8, 0) }
      hand_eval = HandEvaluator.new hand
      result = hand_eval.eval_seven_card_hand

      expect(result.rank).to eq HandResult::RANKS[:straight_flush]
      expect(result.primary).to eq 14
      expect(result.secondary).to eq nil
      expect(result.kicker_values.size).to eq 0
    end

    it 'detects 4-of-a-kind' do
      4.times { hand << deck.pull_card(13) }
      [4, 10, 6].each { |v| hand << deck.pull_card(v) }

      hand_eval = HandEvaluator.new hand
      result = hand_eval.eval_seven_card_hand

      expect(result.rank).to eq HandResult::RANKS[:four_of_a_kind]
      expect(result.primary).to eq 13
      expect(result.secondary).to eq nil
      expect(result.kicker_values.size).to eq 1
      expect(result.kicker_values[0]).to eq 10
    end

    it 'detects full house' do
      3.times { hand << deck.pull_card(13) }
      2.times { hand << deck.pull_card(7) }
      2.times { |i| hand << deck.pull_card(i + 1) }

      hand_eval = HandEvaluator.new hand
      result = hand_eval.eval_seven_card_hand
      expect(result.rank).to eq HandResult::RANKS[:full_house]
      expect(result.primary).to eq 13
      expect(result.secondary).to eq 7
      expect(result.kicker_values.size).to eq 0
    end

    it 'detects flush' do
      [4, 2, 7, 10, 11].each { |v| hand << deck.pull_card(v, 2) }
      [5, 13].each { |v| hand << deck.pull_card(v, 1) }

      hand_eval = HandEvaluator.new hand
      result = hand_eval.eval_seven_card_hand
      expect(result.rank).to eq HandResult::RANKS[:flush]
      expect(result.primary).to eq nil
      expect(result.secondary).to eq nil
      expect(result.kicker_values).to eq [11, 10, 7, 4, 2]
    end

    it 'detects flush' do
      5.times { |v| hand << deck.pull_card((v + 1) * 2, 2) }
      [11, 12].each { |v| hand << deck.pull_card(v, 2) }

      hand_eval = HandEvaluator.new hand
      result = hand_eval.eval_seven_card_hand
      expect(result.rank).to eq HandResult::RANKS[:flush]
      expect(result.primary).to eq nil
      expect(result.secondary).to eq nil
      expect(result.kicker_values).to eq [12, 11, 10, 8, 6]
    end

    it 'detects straight' do
      5.times { |i| hand << deck.pull_card(i + 1, i % 4) }
      2.times { |i| hand << deck.pull_card(i + 10) }

      hand_eval = HandEvaluator.new hand
      result = hand_eval.eval_seven_card_hand
      expect(result.rank).to eq HandResult::RANKS[:straight]
      expect(result.primary).to eq 5
      expect(result.secondary).to eq nil
      expect(result.kicker_values.size).to eq 0
    end

    it 'detects ace-high straight' do
      [12,11,10,13,14].each { |v| hand << deck.pull_card(v, v % 4) }
      2.times { |i| hand << deck.pull_card(i + 10) }

      hand_eval = HandEvaluator.new hand
      result = hand_eval.eval_seven_card_hand
      expect(result.rank).to eq HandResult::RANKS[:straight]
      expect(result.primary).to eq 14
      expect(result.secondary).to eq nil
      expect(result.kicker_values.size).to eq 0
    end

    it 'detects primary card in 7-card straight' do
      7.times { |i| hand << deck.pull_card(12 - i, i % 4) }

      hand_eval = HandEvaluator.new hand
      result = hand_eval.eval_seven_card_hand
      expect(result.rank).to eq HandResult::RANKS[:straight]
      expect(result.primary).to eq 12
      expect(result.secondary).to eq nil
      expect(result.kicker_values.size).to eq 0
    end

    it 'detects 3-of-a-kind' do
      3.times { hand << deck.pull_card(10) }
      [2, 12, 4, 6].each { |n| hand << deck.pull_card(n, n % 4)}

      hand_eval = HandEvaluator.new hand
      result = hand_eval.eval_seven_card_hand
      expect(result.rank).to eq HandResult::RANKS[:three_of_a_kind]
      expect(result.primary).to eq 10
      expect(result.secondary).to eq nil
      expect(result.kicker_values).to eq [12, 6]
    end

    it 'detects two_pair' do
      2.times { hand << deck.pull_card(2) }
      2.times { hand << deck.pull_card(13) }
      hand << deck.pull_card(14)
      2.times { |i| hand << deck.pull_card(i + 6, i % 4) }

      hand_eval = HandEvaluator.new hand
      result = hand_eval.eval_seven_card_hand
      expect(result.rank).to eq HandResult::RANKS[:two_pair]
      expect(result.primary).to eq 13
      expect(result.secondary).to eq 2
      expect(result.kicker_values).to eq [14]
    end

    it 'detects pair' do
      2.times { hand << deck.pull_card(1) }
      [9, 3, 13, 4, 5].each { |n| hand << deck.pull_card(n, n % 4) }

      hand_eval = HandEvaluator.new hand
      result = hand_eval.eval_seven_card_hand
      expect(result.rank).to eq HandResult::RANKS[:pair]
      expect(result.primary).to eq 14
      expect(result.secondary).to eq nil
      expect(result.kicker_values).to eq [13, 9, 5]
    end

    it 'detects high_card' do
      [1, 3, 13, 4, 7, 10, 11].each { |n| hand << deck.pull_card(n, n % 4) }

      hand_eval = HandEvaluator.new hand
      result = hand_eval.eval_seven_card_hand
      expect(result.rank).to eq HandResult::RANKS[:high_card]
      expect(result.primary).to eq 14
      expect(result.secondary).to eq nil
      expect(result.kicker_values).to eq [13, 11, 10, 7]
    end
  end
end
