module Dino
  module Components
    module Basic
      class PWMOut < DigitalOutput
        interrupt_with :write

        def pwm_write(value)
          board.pwm_write(pin, @state = value)
        end

        def write(value)
          if value == board.low
            digital_write(board.low)
          elsif value == board.analog_high
            digital_write(board.high)
          else
            pwm_write(value)
          end
        end
      end
    end
  end
end
