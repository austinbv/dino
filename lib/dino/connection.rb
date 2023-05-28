module Dino
  module Connection
    autoload :FlowControl,  "#{__dir__}/connection/flow_control"
    autoload :Handshake,    "#{__dir__}/connection/handshake"
    autoload :Base,         "#{__dir__}/connection/base"
    autoload :Serial,       "#{__dir__}/connection/serial"
    autoload :TCP,          "#{__dir__}/connection/tcp"
  end
end
