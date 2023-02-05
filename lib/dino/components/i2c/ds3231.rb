module Dino
  module Components
    module I2C
      class DS3231 < Slave
        require 'bcd'
        
        def time
          read_using -> { _read }
          state
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
        
        # Time data starts at register 0 and is 7 bytes long.
        def _read
          read_bytes(0, 7)
        end
        
        # Convert raw bytes from the I2C bus into a Ruby Time object.
        def pre_callback_filter(bytes)
          t = bytes.map { |b| BCD.encode(b) }
          Time.new t[6] + 1970, t[5], t[4], t[2], t[1], t[0]
        end
      end
    end
  end
end
