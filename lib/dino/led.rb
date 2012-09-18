module Dino
  class Led
    def initialize(hash)
      @pin, @board = hash[:pin], hash[:board]
      raise 'a board and a pin are required for an led' if @board.nil? || @pin.nil?

      @board.set_pin_mode(@pin, :out)
      @board.digital_write(@pin, Board::LOW)
    end

    def on
      @board.digital_write(@pin, Board::HIGH)
    end

    def off
      @board.digital_write(@pin, Board::LOW)
    end
  end
end