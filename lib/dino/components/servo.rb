module Dino
  module Components
    class Servo
      include Setup::SinglePin
      include Mixins::Threaded

      def after_initialize(options={})
        super(options)
        @min = options[:min] || 544
        @max = options[:max] || 2400
        attach
      end

      def attach
        board.servo_toggle(pin, :on, min: @min, max: @max)
      end

      def detach
        board.servo_toggle(pin, :off, min: @min, max: @max)
      end

      def position=(value)
        value = value % 180 unless value == 180

        microseconds = ((value.to_f / 180) * (@max - @min)) + @min
        board.servo_write(pin, microseconds.ceil)

        @state = value
      end

      alias :angle=   :position=
      alias :angle    :state
      alias :position :state

      def write_microseconds(value)
        raise 'invalud microsecond value' if value > @max || value < @min
        board.servo_write(pin, value)
      end
    end
  end
end
