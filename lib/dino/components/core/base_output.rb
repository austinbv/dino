module Dino
  module Components
    module Core
      class BaseOutput < Base
        attr_reader :state

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
          unless [Board::LOW, Board::HIGH].include? value
            analog_write(value)
          else
            digital_write(value)
          end
        end

        def low
          digital_write Board::LOW
        end

        def high
          digital_write Board::HIGH
        end

        alias :off :low
        alias :on  :high
      end
    end
  end
end
