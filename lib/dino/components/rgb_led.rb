module Dino
  module Components
    class RgbLed < BaseComponent
      # options = {board: my_board, pins: {red: red_pin, green: green_pin, blue: blue_pin}
      def after_initialize(options={})
        raise 'missing pins[:red] pin' unless self.pins[:red]
        raise 'missing pins[:green] pin' unless self.pins[:green]
        raise 'missing pins[:blue] pin' unless self.pins[:blue]

        pins.each do |color, pin|
          set_pin_mode(pin, :out)
          analog_write(pin, Board::LOW)
        end
      end

      def blue
        analog_write(pins[:red], Board::LOW)
        analog_write(pins[:green], Board::LOW)
        analog_write(pins[:blue], Board::HIGH)
      end

      def red
        analog_write(pins[:red], Board::HIGH)
        analog_write(pins[:green], Board::LOW)
        analog_write(pins[:blue], Board::LOW)
      end

      def green
        analog_write(pins[:red], Board::LOW)
        analog_write(pins[:green], Board::HIGH)
        analog_write(pins[:blue], Board::LOW)
      end

      def blinky
        [:red, :green, :blue].cycle do |color|
          self.send(color)
          sleep(0.01)
        end
      end
    end
  end
end
