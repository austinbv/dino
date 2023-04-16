module Dino
  module SPI
    autoload :Bus,            "#{__dir__}/spi/bus"
    autoload :BitBang,        "#{__dir__}/spi/bit_bang"
    autoload :BaseRegister,   "#{__dir__}/spi/base_register"
    autoload :InputRegister,  "#{__dir__}/spi/input_register"
    autoload :OutputRegister, "#{__dir__}/spi/output_register"
  end
end
