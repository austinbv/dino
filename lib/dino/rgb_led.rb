module Dino
  class RgbLed
    def initialize(hash)
      @red_pin, @green_pin, @blue_pin, @board = hash[:red_pin], hash[:green_pin], hash[:blue_pin], hash[:board]

      [@red_pin, @green_pin, @blue_pin].each do |pin|
        @board.set_pin_mode(pin, :out)
        @board.analog_write(pin, Board::HIGH)
      end
    end

    def color(red, green, blue)
      @board.analog_write(@red_pin, red)
      @board.analog_write(@green_pin, green)
      @board.analog_write(@blue_pin, blue)
    end

    def blue
      @board.analog_write(@red_pin, Board::HIGH)
      @board.analog_write(@green_pin, Board::HIGH)
      @board.analog_write(@blue_pin, Board::LOW)
    end

    def red
      @board.analog_write(@red_pin, Board::LOW)
      @board.analog_write(@green_pin, Board::HIGH)
      @board.analog_write(@blue_pin, Board::HIGH)
    end

    def green
      @board.analog_write(@red_pin, Board::HIGH)
      @board.analog_write(@green_pin, Board::LOW)
      @board.analog_write(@blue_pin, Board::HIGH)
    end

    def off
      @board.analog_write(@red_pin, Board::HIGH)
      @board.analog_write(@green_pin, Board::HIGH)
      @board.analog_write(@blue_pin, Board::HIGH)
    end

    def blinky
      [Board::HIGH, Board::LOW].cycle do |level|
        @board.digital_write(@red_pin, level)
        @board.digital_write(@green_pin, level)
        @board.digital_write(@blue_pin, level)
        sleep(0.01)
      end
    end
  end
end