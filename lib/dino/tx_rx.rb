module Dino
  module TxRx
    require 'dino/tx_rx/usb'
    require 'dino/tx_rx/telnet'

    def self.new
      self::USB.new
    end
  end
end