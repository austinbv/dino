module Dino
  module Board
    module API
      module ShiftIO
        include Helper

        def shift_settings(data, clock, bit_order=:lsbfirst, preclock_high=false)
          settings = 0b00
          settings |= 0b01 if bit_order == :msbfirst
          settings |= 0b10 if preclock_high
          pack :uint8, [convert_pin(data), convert_pin(clock), settings]
        end

        # CMD = 21
        def shift_write(latch, data, clock, bytes, options={})
          settings = shift_settings(data, clock, options[:bit_order])
          limit = aux_limit - settings.length
          bytes = pack :uint8, bytes, max: limit

          write Message.encode command: 21,
                              pin: convert_pin(latch),
                              value: bytes.length,
                              aux_message: settings + bytes
        end

        # CMD = 22
        def shift_read(latch, data, clock, num_bytes, options={})
          settings = shift_settings(data, clock, options[:bit_order], options[:preclock_high])
          write Message.encode command: 22,
                              pin: convert_pin(latch),
                              value: num_bytes,
                              aux_message: settings
        end

        # CMD = 23
        def shift_listen(latch, data, clock, num_bytes, options={})
          settings = shift_settings(data, clock, options[:bit_order], options[:preclock_high])
          write Message.encode command: 23,
                              pin: convert_pin(latch),
                              value: num_bytes,
                              aux_message: settings
        end

        # CMD = 24
        def shift_stop(latch)
          write Message.encode command: 24, pin: convert_pin(latch)
        end
      end
    end
  end
end
