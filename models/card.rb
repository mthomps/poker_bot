require 'active_model'

class Card
  include Comparable
  attr_accessor :value, :suit

  def initialize(value, suit)
    @value = value
    @suit = suit
    raise ArgumentError.new "Invalid value or suit: \"#{@value} of #{@suit}\"" unless is_valid?
  end

  def <=>(other)
    @value <=> other.value
  end


  private

  def is_valid?
    @value.is_a?(Integer) && @value >= 1 && @value <= 14 &&
    @suit.is_a?(Integer) && @suit >= 0 && @suit <= 3
  end
end
