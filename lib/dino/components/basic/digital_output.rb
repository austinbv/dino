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
        alias :off :low

        def low?
          state == board.low
        end
        alias :off? :low?

        def high
          digital_write(board.high)
        end
        alias :on  :high

        def high?
          state == board.high
        end
        alias :on?  :high?

        def toggle
          low? ? high : low
        end
      end
    end
  end
end
