module Dino
  module TxRx
    require 'dino/tx_rx/serial'
    require 'dino/tx_rx/telnet'

    def self.new
      self::Serial.new
    end
  end
end