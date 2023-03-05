module Dino
  module Components
    class SSD
      include Setup::MultiPin
      
      def initialize_pins(options={})        
        proxy_pin :a, Basic::DigitalOutput
        proxy_pin :b, Basic::DigitalOutput
        proxy_pin :c, Basic::DigitalOutput
        proxy_pin :d, Basic::DigitalOutput
        proxy_pin :e, Basic::DigitalOutput
        proxy_pin :f, Basic::DigitalOutput
        proxy_pin :g, Basic::DigitalOutput
        
        proxy_pin :cathode, Basic::DigitalOutput, optional: true
        proxy_pin :anode,   Basic::DigitalOutput, optional: true
      end
      
      # ssd = SevenSegmentDisplay.new(
      #   board: board,
      #   pins:  {anode: 11, a: 12, b: 13, c: 3,d: 4, e: 5, f: 10, g: 9}
      # )
      def after_initialize(options={})
        @segments = [a,b,c,d,e,f,g]
        clear; on
      end

      attr_reader :segments

      def clear
        segments.each do |pin|
          pin.low if cathode
          pin.high if anode
        end
      end

      def display(char)
        char = char.to_s
        return scroll(char) if char.length > 1
        off; write(char); on
      end

      def on
        anode.high if anode
        cathode.low if cathode
      end

      def off
        anode.low if anode
        cathode.high if cathode
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
        'S' => [1,0,1,1,0,1,1],
        'T' => [0,0,0,1,1,1,1],
        'U' => [0,0,1,1,1,0,0],
        'V' => [0,1,1,1,1,1,0],
        'W' => [0,1,1,1,1,1,1],
        'X' => [0,1,1,0,1,1,1],
        'Y' => [0,1,1,1,0,1,1],
        'Z' => [1,1,0,1,1,0,0],
      }

      private

      def write(char)
        bits = CHARACTERS[char.to_s.upcase]
        unless bits
          clear
        else
          bits.each_with_index do |bit, index|
            if anode
              bit == 0 ? bit = 1 : bit = 0
            end
            segments[index].write(bit) unless (segments[index].state == bit)
          end
        end
      end

      def scroll(string)
        string.chars.each do |char|
          display(char)
          sleep(0.5)
        end
      end
    end
  end
end
