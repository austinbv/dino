module Dino
  module API
    module LEDArray
      include Helper

      def show_ws2812(pin, pixel_buffer)
        length = pixel_buffer.length

        # Settings are blank for now.
        settings = pack :uint8, [0, 0, 0, 0]
        
        # Limit to 100 pixels (3-bytes each) for now
        packed_pixels = pack :uint8, pixel_buffer, max: 300

        write_and_halt Message.encode command: 19,
                                      pin: convert_pin(pin),
                                      value: length,
                                      aux_message: settings + packed_pixels
      end
    end
  end
end
