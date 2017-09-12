module Dino
  module Components
    class IREmitter < Basic::DigitalOutput
      def send(pulses=[], options={})
        raise Exception.new('infrared signals are limited to a total of 255 pulses (marks + ticks)') if pulses.length > 255
        pulses.each do |p|
          raise Exception.new('invalid infrared signal, please ensure all microsecond durations are integers') unless p.is_a? Integer
          raise Exception.new('pulse lengths are limited to 65536 microseconds') if p > 65536
        end

        # Default to 38kHz
        frequency = options[:freqency] || 38

        message = Dino::Message.encode(
          command: 16,
          # Setting the IR emitter pin is currently unsupported.
          # Although the value gets passed through, it always uses the default pin
          # for your specfic board/chip, as defined by the library (in bold) at:
          # https://github.com/z3t0/Arduino-IRremote#hardware-specifications
          pin: pin,
          value: frequency,
          aux_message: pack(pulses)
        )
        board.write(message)
      end

      # Pack pulse lengths (in microseconds) into a string (byte array really) such that:
      # 1) Each pulse length is converted to a little-endian unsigned 16-bit integer.
      # 2) Each pulse occupies 2 consecutive bytes of the byte array.
      # 3) The first pulse is at index 1 of the array, and subsequent pulses
      #    start on consecutive odd-numbered indices.
      # 4) The 0th byte of the array contains the total number of pulses (NOT bytes).
      #
      # This keeps compatbility with the aux format normally used for sending data as
      # ASCII, but sends higher density binary data whch the IR library needs.
      #
      def pack(pulses=[])
        "#{[pulses.count].pack('C')}#{pulses.pack('v*')}"
      end
    end
  end
end
