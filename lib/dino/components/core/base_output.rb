module Dino
  module Components
    module Core
      class BaseOutput < Base
        include Threaded
        interrupt_with :digital_write, :analog_write

        def initialize(options={})
          super options

          self.mode = :out
          low
        end

        def digital_write(value)
          board.digital_write(pin, @state = value)
        end

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

        def low
          digital_write(board.low)
        end

        def high
          digital_write(board.high)
        end

        def toggle
          state == board.low ? high : low
        end

        alias :off :low
        alias :on  :high
      end
    end
  end
end
