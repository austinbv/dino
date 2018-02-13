module Dino
  module API
    module ShiftIO
      include Helper

      def shift_settings(data, clock, preclock_high=false)
        preclock_high = preclock_high ? 1 : 0
        pack :uint8, [convert_pin(data), convert_pin(clock), preclock_high]
      end

      def shift_write(latch, data, clock, byte_array, options={})
        settings = shift_settings(data, clock)
        limit = aux_limit - settings.length
        bytes = pack :uint8,
                     byte_array,
                     max: (limit < 256) ? limit : 256

        write Message.encode command: 21,
                             pin: convert_pin(latch),
                             value: bytes.length, # Should be length-1 so 0 = 1 byte, 255 = 256 bytes
                             aux_message: settings + bytes
      end

      def shift_read(latch, data, clock, num_bytes, options={})
        settings = shift_settings(data, clock, options[:preclock_high])
        write Message.encode command: 22,
                             pin: convert_pin(latch),
                             value: num_bytes, # Should be num-1 so 0 = 1 byte, 255 = 256 bytes
                             aux_message: settings
      end

      def shift_listen(latch, data, clock, num_bytes, options={})
        settings = shift_settings(data, clock, options[:preclock_high])
        write Message.encode command: 23,
                             pin: convert_pin(latch),
                             value: num_bytes, # Should be num-1 so 0 = 1 byte, 255 = 256 bytes
                             aux_message: settings
      end

      def shift_stop(latch)
        write Message.encode command: 24, pin: convert_pin(latch)
      end
    end
  end
end
