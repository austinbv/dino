module Dino
  module Board
    module Connection
      autoload :FlowControl,  "#{__dir__}/connection/flow_control"
      autoload :Handshake,    "#{__dir__}/connection/handshake"
      autoload :Base,         "#{__dir__}/connection/base"
      autoload :Serial,       "#{__dir__}/connection/serial"
      autoload :TCP,          "#{__dir__}/connection/tcp"
      
      def self.new(options={})
        self::Serial.new(options)
      end
    end
  end
end
