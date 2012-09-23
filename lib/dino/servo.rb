module Dino
  class Servo
    attr_reader :position

    def initialize(hash)
      @pin, @board = hash[:pin], hash[:board]
      raise 'a board and a pin are required for an led' if @board.nil? || @pin.nil?

      @board.set_pin_mode(@pin, :out)
      self.position = 0
    end

    def position=(new_position)
      @position = new_position % 180
      @board.analog_write(@pin, @position)
    end
  end
end

