module Dino
  module Components
    module Basic
      class DigitalOutput
        include Setup::SinglePin
        include Setup::Output
        include Mixins::Threaded
        interrupt_with :digital_write

        def after_initialize(options={})
          low
        end

        def digital_write(value)
          board.digital_write(pin, @state = value)
        end

        alias :write :digital_write

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
