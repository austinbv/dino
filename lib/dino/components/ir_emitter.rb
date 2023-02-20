module Dino
  module Components
    class IREmitter < Basic::DigitalOutput
      def emit(pulses=[], options={})
        if pulses.length > 256 || pulses.length < 1
          raise ArgumentError, 'wrong number of IR pulses (expected 1 to 256)'
        end

        pulses.each_with_index do |pulse, index|
          raise ArgumentError, 'non Numeric data in IR signal' unless pulse.is_a? Numeric
          pulses[index] = pulse.round unless pulse.is_a? Integer
          raise ArgumentError, 'pulse too long (max 65535 ms)' if pulse > 65535
        end

        frequency = options[:frequency] || 38
        board.infrared_emit(pin, frequency, pulses)
      end
    end
  end
end
