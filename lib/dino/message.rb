module Dino
  module Message
    BYTE_RANGE = (0..255)

    def self.encode(options={})
      cmd = options[:command]
      pin = options[:pin]
      val = options[:value]
      aux = options[:aux_message]
      aux = aux.to_s.gsub("\\","\\\\\\\\").gsub("\n", "\\\n") if aux

      unless cmd && BYTE_RANGE.include?(cmd)
        raise ArgumentError, 'command missing or not integer in range 0 to 255'
      end
      if pin && !BYTE_RANGE.include?(pin)
        raise ArgumentError, 'pin must be integer in range 0 to 255'
      end
      if val && !BYTE_RANGE.include?(val)
        raise ArgumentError, 'value must be integer in range 0 to 255'
      end
      if aux.to_s.length > 512
        raise ArgumentError, 'auxillary messages are limited to 512 characters'
      end

      message = ""
      [aux, val, pin].each do |fragment|
        if fragment
          message = ".#{fragment}" << message
        elsif !message.empty?
          message = "." << message
        end
      end
      message = "#{cmd}" << message
      message << "\n"
    end
  end
end
