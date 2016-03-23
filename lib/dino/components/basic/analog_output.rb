module Dino
  module Components
    module Basic
      class AnalogOutput < DigitalOutput
        interrupt_with :analog_write

        def analog_write(value)
          board.analog_write(pin, @state = value)
        end

        def write(value)
          unless [board.low, board.high].include? value
            analog_write(value)
          else
            digital_write(value)
          end
        end
      end
    end
  end
end
