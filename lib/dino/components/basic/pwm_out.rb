module Dino
  module Components
    module Basic
      class PWMOut < DigitalOutput
        interrupt_with :write
        
        def initialize_pins(options={})
          super(options)
        end

        def write(value)
          if value == board.low
            digital_write(board.low)
          elsif value == board.pwm_high
            digital_write(board.high)
          else
            pwm_write(value)
          end
        end

        def pwm_write(value)
          pwm_enable
          board.pwm_write(pin, @state = value)
        end

        def pwm_enable
          self.mode = :output_pwm unless mode == :output_pwm
        end
        
        def pwm_disable
          self.mode = :output
        end
      end
    end
  end
end
