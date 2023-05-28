module Dino
  class Board
    # CMD = 9
    def pulse_read(pin, **options)
      # Hold the input pin high or low before reading.
      # Give as 1 (high) or 0 (low) values to the :reset key.
      options[:reset] ||= false
      
      # How long to hold the rest for, in milliseconds.
      options[:reset_time] ||= 0
      begin
        raise ArgumentError if (options[:reset_time] < 0) || (options[:reset_time] > 0xFFFF)
      rescue 
        raise ArgumentError, "error in reset time: #{options[:reset_time]}. Should be Integer in range 0..65535 ms"
      end

      # Maximum number of pulses to capture.
      options[:pulse_limit] ||= 100
      begin
        raise ArgumentError if (options[:pulse_limit] < 0) || (options[:pulse_limit] > 0xFF)
      rescue
        raise ArgumentError, "error in pulse limit: #{options[:pulse_limit]}. Should be Integer in range 0..255 pulses"
      end

      # A pulse of this length will end the read.
      options[:timeout] ||= 200
      begin
        raise ArgumentError if (options[:timeout] < 0) || (options[:timeout] > 0xFFFF)
      rescue
        raise ArgumentError, "error in timeout: #{options[:timeout]}. Should be Integer in range 0..65535 ms"
      end
      
      # Bit 0 of settings mask controls whether to hold high/low for reset.
      settings = options[:reset] ? 1 : 0

      # Bit 1 of settings mask controls whether to hold high (1) or to hold low (0).
      settings = settings | 0b10 if (options[:reset] && options[:reset] != low)

      # Pack and send.
      aux = pack :uint16, [options[:reset_time], options[:timeout]]
      aux << pack(:uint8, options[:pulse_limit])
      write Message.encode  command: 9,
                            pin: pin,
                            value: settings,
                            aux_message: aux
    end
  end
end
