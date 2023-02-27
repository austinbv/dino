module Dino
  module Components
    class DHT
      include Setup::SinglePin
      include Setup::Input
      include Mixins::Poller

      def _read
        board.pulse_read(pin, reset: board.low, reset_time: 1000, pulse_limit: 84)
      end

      def pre_callback_filter(data)
        decode(data.split(",").map(&:to_i))
      end

      def decode(data)
        data = data.last(81)
        return { error: 'missing data' } unless data.length == 81
        data = data[0..79]

        bytes = []
        data.each_slice(16) do |b|
          byte = 0b00000000
          b.each_slice(2) do |x,y|
            bit = (y<x) ? 0 : 1
            byte = (byte << 1) | bit
          end
          bytes << byte
        end
        return { error: 'CRC failure' } unless crc(bytes)

        celsius   = ((bytes[2] << 8) | bytes[3]).to_f / 10
        humidity  = ((bytes[0] << 8) | bytes[1]).to_f / 10
        fahrenheit = (celsius * 1.8 + 32).round(1)

        { celsius: celsius, fahrenheit: fahrenheit, humidity: humidity }
      end

      def crc(bytes)
        bytes[0..3].reduce(0, :+) & 0xFF == bytes[4]
      end
    end
  end
end
