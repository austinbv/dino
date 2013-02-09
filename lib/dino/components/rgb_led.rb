module Dino
  module Components
    class RgbLed < BaseComponent
      # options = {board: my_board, pins: {red: red_pin, green: green_pin, blue: blue_pin}
      def after_initialize(options={})
        raise 'missing pins[:red] pin' unless self.pins[:red]
        raise 'missing pins[:green] pin' unless self.pins[:green]
        raise 'missing pins[:blue] pin' unless self.pins[:blue]

        pins.each do |color, pin|
          set_pin_mode(:out, pin)
          analog_write(Board::LOW, pin)
        end
      end

      def blue
        analog_write(Board::LOW, pins[:red])
        analog_write(Board::LOW, pins[:green])
        analog_write(Board::HIGH, pins[:blue])
      end

      def red
        analog_write(Board::HIGH, pins[:red])
        analog_write(Board::LOW, pins[:green])
        analog_write(Board::LOW, pins[:blue])
      end

      def green
        analog_write(Board::LOW, pins[:red])
        analog_write(Board::HIGH, pins[:green])
        analog_write(Board::LOW, pins[:blue])
      end

      def cyan
        analog_write(Board::LOW,  pins[:red])
        analog_write(Board::HIGH, pins[:green])
        analog_write(Board::HIGH, pins[:blue])
      end

      def yellow
        analog_write(Board::HIGH, pins[:red])
        analog_write(Board::HIGH, pins[:green])
        analog_write(Board::LOW,  pins[:blue])
      end

      def magenta
        analog_write(Board::HIGH, pins[:red])
        analog_write(Board::LOW,  pins[:green])
        analog_write(Board::HIGH, pins[:blue])
      end

      def white
        analog_write(Board::HIGH, pins[:red])
        analog_write(Board::HIGH, pins[:green])
        analog_write(Board::HIGH, pins[:blue])
      end

      def off
        analog_write(Board::LOW,  pins[:red])
        analog_write(Board::LOW,  pins[:green])
        analog_write(Board::LOW,  pins[:blue])
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
