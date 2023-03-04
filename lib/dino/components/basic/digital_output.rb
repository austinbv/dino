module Dino
  module Components
    module Basic
      class DigitalOutput
        include Setup::SinglePin
        include Setup::Output
        include Mixins::Callbacks
        include Mixins::Threaded
        interrupt_with :digital_write

        def after_initialize(options={})
          super(options)
          board.digital_read(pin)
        end

        def pre_callback_filter(board_state)
          board_state.to_i
        end

        def digital_write(value)
          value = value.to_i
          value = board.high unless (value == board.low)
          board.digital_write(pin, value)
          self.state = value
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
        
        def high?; state == board.high end
        def low?;  state == board.low  end
        
        alias :on?  :high?
        alias :off? :low?
      end
    end
  end
end
