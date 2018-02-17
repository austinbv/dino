module Dino
  module Components
    module I2C
      class DS3231 < Slave
        require 'bcd'

        def pre_callback_filter(bytes)
          t = bytes.map { |b| BCD.encode(b) }
          Time.new t[6] + 1970, t[5], t[4], t[2], t[1], t[0]
        end

        def time
          # Return of read_bytes is still unfiltered string from the bus...
          read_using -> { read_bytes(nil, 7) }
          @state
        end

        def time=(time)
          bytes = [ 0,
                    BCD.decode(time.sec),
                    BCD.decode(time.min),
                    BCD.decode(time.hour),
                    BCD.decode(time.strftime('%u').to_i),
                    BCD.decode(time.day),
                    BCD.decode(time.month),
                    BCD.decode(time.year - 1970) ]
          write(bytes)
          time
        end
      end
    end
  end
end
