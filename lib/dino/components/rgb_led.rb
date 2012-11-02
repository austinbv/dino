module Dino
  module Components
    class RgbLed < BaseComponent
      # options = {board: my_board, pins: {red: red_pin, green: green_pin, blue: blue_pin}
      def initialize(options={})
        super(options)
        self.pins.merge!(self.pins) {|k, v| Led.new(pin: v, board: options[:board])}
      end

      def set(options={})
        options.each{|k, v| self.pins[k].set(v)}
      end

      def color(color)
        self.pins[color]
      end

      def blue
        self.pins[:red].off
        self.pins[:green].off
        self.pins[:blue].on
      end

      def red
        self.pins[:red].on
        self.pins[:green].off
        self.pins[:blue].off
      end

      def green
        self.pins[:red].off
        self.pins[:green].on
        self.pins[:blue].off
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
