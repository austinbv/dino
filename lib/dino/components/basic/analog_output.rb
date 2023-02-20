module Dino
  module Components
    module Basic
      class AnalogOutput < DigitalOutput
        interrupt_with :analog_write

        def analog_write(value)
          board.analog_write(pin, @state = value)
        end

        def write(value)
          if value == board.low
            digital_write(board.low)
          elsif value == board.analog_high
            digital_write(board.high)
          else
            analog_write(value)
          end
        end
      end
    end
  end
end
