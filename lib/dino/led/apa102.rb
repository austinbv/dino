module Dino
  module LED
    class APA102
      include SPI::Peripheral

      attr_reader :length, :bpp

      def after_initialize(options={})
        super(options)
        raise ArgumentError, "no length given for APA102 array" unless options[:length]
        @length = options[:length]

        # This is BYTES per pixel, not bits per pixel.
        # 0th byte is per-pixel brightness (current).
        @bpp = 4
        off
      end

      def []=(index, array)
        # Force max brightness for now.
        buffer[index*bpp+0] = 31

        # APA102 uses BGR ordering.
        buffer[index*bpp+1] = array[2]
        buffer[index*bpp+2] = array[1]
        buffer[index*bpp+3] = array[0]
      end

      def buffer
        @buffer ||= Array.new(length * bpp) { 0 }
      end

      def all_on
        @buffer = buffer.each_slice(bpp).map { [31,255,255,255] }.flatten
        show
      end

      def off
        clear
        show
      end

      def clear
        @buffer = buffer.each_slice(bpp).map { [31,0,0,0] }.flatten
      end

      def show
        write([0,0,0,0] + buffer + [0,0,0,0])
      end
    end
  end
end
