module Dino
  module Board
    module API
      module Message
        BYTE_MAX = 255
        VAL_MIN = 0
        VAL_MAX = 9999

        def self.encode(options={})
          cmd = options[:command]
          pin = options[:pin]
          val = options[:value]
          aux = options[:aux_message]
          aux = aux.to_s.gsub("\\","\\\\\\\\").gsub("\n", "\\\n") if aux

          raise ArgumentError, 'command missing from message' unless cmd

          if cmd.class != Integer || cmd < 0 || cmd > BYTE_MAX
            raise ArgumentError, 'command missing or not integer in range 0 to 255'
          end
          if pin && (pin.class != Integer || pin < 0 || pin > BYTE_MAX)
            raise ArgumentError, 'pin must be integer in range 0 to 255'
          end
          if val && (val.class != Integer || val < VAL_MIN || val > VAL_MAX)
            raise ArgumentError, "value must be integer in range 0 to 9999"
          end
          if aux.to_s.length > 527
            raise ArgumentError, 'auxillary messages are limited to 528 characters'
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
  end
end
