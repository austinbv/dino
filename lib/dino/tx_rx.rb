module Dino
  module TxRx
    require 'dino/tx_rx/base'
    require 'dino/tx_rx/usb_serial'
    require 'dino/tx_rx/tcp'

    def self.new(device = nil)
      self::USBSerial.new(device)
    end
  end
end