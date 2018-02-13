module Dino
  module Components
    class IREmitter < Basic::DigitalOutput
      def send(pulses=[], options={})
        if pulses.length > 256 || pulses.length < 1
          raise ArgumentError, 'wrong number of IR pulses (expected 1 to 256)'
        end

        pulses.each_with_index do |pulse, index|
          raise ArgumentError, 'non Numeric data in IR signal' unless pulse.is_a? Numeric
          pulses[index] = pulse.round unless pulse.is_a? Integer
          raise ArgumentError 'pulse too long (max 65536 microsec)' if pulse > 65536
        end

        # Default to 38kHz.
        frequency = options[:frequency] || 38

        board.infrared_send(pin, frequency, pulses)
      end
    end
  end
end
