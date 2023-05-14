module Dino
  module LED
    class APA102
      include SPI::Peripheral

      attr_reader :length, :bpp, :brightness

      def after_initialize(options={})
        super(options)

        raise ArgumentError, "no length given for APA102 array" unless options[:length]
        @length = options[:length]

        # Start frame is always 32 0-bits (4 bytes).
        @start_frame = Array.new(4) { 0 }

        # End frame must be at least @length/2 bits long, and 32 bits (4 bytes) minimum.
        end_frame_bytes = (@length / 16.0).ceil
        end_frame_bytes = 4 if end_frame_bytes < 4

        # Use all 0's for end frame instead of 1's. Prevents extra pixel when using partial strip.
        @end_frame = Array.new(end_frame_bytes) { 0 }

        # This is BYTES per pixel, not bits per pixel.
        # 0th byte is per-pixel brightness (PWM applied to all 3 colors).
        @bpp = 4
        @buffer = Array.new(length * bpp) { 0 }

        # Default to max brightness.
        self.brightness = 31
        
        off
      end

      # Global (per-strip) brightness control.
      def brightness=(value)
        value = 31 if value > 31
        value = 0 if value < 0
        @brightness = value

        # @masked_brightness needs to set the 3 bits above the 5 used.
        @masked_brightness = 0b11100000 | @brightness

        # Set brightness for all pixels.
        (0..@length-1).each do |index|
          @buffer[index*bpp+0] = @masked_brightness
        end
      end

      def []=(index, array)
        # Per-pixel brightness control, as optional 3rd indexed element of array.
        if array[3]
          @buffer[index*bpp+0] = 0b11100000 | array[3]
        end
        
        # APA102 uses BGR ordering.
        @buffer[index*bpp+1] = array[2]
        @buffer[index*bpp+2] = array[1]
        @buffer[index*bpp+3] = array[0]
      end

      def all_on
        self.brightness = 31
        @buffer = @buffer.each_slice(bpp).map { [@masked_brightness,255,255,255] }.flatten
        show
      end

      def off
        clear
        show
      end

      def clear
        @buffer = @buffer.each_slice(bpp).map { [@masked_brightness,0,0,0] }.flatten
      end

      def show
        write(@start_frame + @buffer + @end_frame)
      end
    end
  end
end
