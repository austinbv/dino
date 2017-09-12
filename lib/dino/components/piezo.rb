module Dino
  module Components
    class Piezo < Basic::AnalogOutput
      include Setup::SinglePin
      include Setup::Output
      include Mixins::Threaded
      interrupt_with :digital_write

      def after_initialize(options={})
        low
      end

      # Duration is in mills
      def tone(value, duration = 500)
        board.tone pin, value, duration
      end

      def no_tone
        board.no_tone pin
      end
    end
  end
end
