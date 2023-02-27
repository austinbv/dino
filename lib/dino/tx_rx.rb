module Dino
  module TxRx
    require 'dino/tx_rx/flow_control'
    require 'dino/tx_rx/handshake'
    require 'dino/tx_rx/base'
    require 'dino/tx_rx/serial'
    require 'dino/tx_rx/tcp'

    def self.new(options={})
      self::Serial.new(options)
    end
  end
end
