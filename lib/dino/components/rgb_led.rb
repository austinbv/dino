module Dino
  module Components
    class RGBLed
      include Setup::MultiPin

      def initialize_pins(options={})
        proxy_pin :red,   Basic::AnalogOutput
        proxy_pin :green, Basic::AnalogOutput
        proxy_pin :blue,  Basic::AnalogOutput
      end

      # Format: [R, G, B]
      COLORS = {
        red:     [255, 000, 000],
        green:   [000, 255, 000],
        blue:    [000, 000, 255],
        cyan:    [000, 255, 255],
        yellow:  [255, 255, 000],
        magenta: [255, 000, 255],
        white:   [255, 255, 255],
        off:     [000, 000, 000]
      }

      def write(array)
        red.write   array[0]
        green.write array[1]
        blue.write  array[2]
      end

      def color=(color)
        return write(color) if color.class == Array

        color = color.to_sym
        write(COLORS[color]) if COLORS.include? color
      end
    end
  end
end
