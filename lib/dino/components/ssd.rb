# Connect to the Arduino and
# take control of the SSD
#
# ssd = SevenSegmentDisplay.new(
#   board: Board.new(TxRx.new),
#   pins:  [12,13,3,4,5,10,9],
#   anode: 11
# )

module Dino
  module Components
    class SSD < BaseComponent
      attr_reader :anode

      def after_initialize(options={})
        @anode = options[:anode]

        raise Exception.new('anode must be specified') unless anode

        # Set all pins to output
        pins.each { |pin| set_pin_mode(pin, :out) }

        # Clear the display
        clear

        # Turn on the display
        on
      end

      def clear
        7.times { |t| toggle t, 0 }
      end

      def display(char)
        key = char.to_s.upcase

        return scroll(key) if key.length > 1

        # Make sure the ssd is turned on.
        on

        if chars = CHARACTERS[key]
          chars.each_with_index { |s,i| toggle i, s }
        else
          clear
        end
      end

      def on
        digital_write anode, Board::HIGH
      end

      def off
        digital_write anode, Board::LOW
      end

      CHARACTERS = {
        '0' => [1,1,1,1,1,1,0],
        '1' => [0,1,1,0,0,0,0],
        '2' => [1,1,0,1,1,0,1],
        '3' => [1,1,1,1,0,0,1],
        '4' => [0,1,1,0,0,1,1],
        '5' => [1,0,1,1,0,1,1],
        '6' => [1,0,1,1,1,1,1],
        '7' => [1,1,1,0,0,0,0],
        '8' => [1,1,1,1,1,1,1],
        '9' => [1,1,1,1,0,1,1],
        ' ' => [0,0,0,0,0,0,0],
        '_' => [0,0,0,1,0,0,0],
        '-' => [0,0,0,0,0,0,1],
        'A' => [1,1,1,0,1,1,1],
        'B' => [0,0,1,1,1,1,1],
        'C' => [0,0,0,1,1,0,1],
        'D' => [0,1,1,1,1,0,1],
        'E' => [1,0,0,1,1,1,1],
        'F' => [1,0,0,0,1,1,1],
        'G' => [1,0,1,1,1,1,0],
        'H' => [0,0,1,0,1,1,1],
        'I' => [0,0,1,0,0,0,0],
        'J' => [0,1,1,1,1,0,0],
        'K' => [1,0,1,0,1,1,1],
        'L' => [0,0,0,1,1,1,0],
        'M' => [1,1,1,0,1,1,0],
        'N' => [0,0,1,0,1,0,1],
        'O' => [0,0,1,1,1,0,1],
        'P' => [1,1,0,0,1,1,1],
        'Q' => [1,1,1,0,0,1,1],
        'R' => [0,0,0,0,1,0,1],
        'S' => [0,0,1,1,0,1,1],
        'T' => [0,0,0,1,1,1,1],
        'U' => [0,0,1,1,1,0,0],
        'V' => [0,1,1,1,1,1,0],
        'W' => [0,1,1,1,1,1,1],
        'X' => [0,1,1,0,1,1,1],
        'Y' => [0,1,1,1,0,1,1],
        'Z' => [1,1,0,1,1,0,0],
      }

      private

      def scroll(string)
        string.chars.each do |chr|
          off
          sleep 0.05
          display chr
          sleep 0.5
        end

        clear
      end

      def toggle(number, state)
        digital_write pins[number], state == 1 ? 0 : 1
      end
    end
  end
end
