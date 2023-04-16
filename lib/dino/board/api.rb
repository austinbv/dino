module Dino
  module Board
    module API
      autoload :Message,    "#{__dir__}/api/message"
      autoload :Helper,     "#{__dir__}/api/helper"
      autoload :Core,       "#{__dir__}/api/core"
      autoload :Pulse,      "#{__dir__}/api/pulse"
      autoload :EEPROM,     "#{__dir__}/api/eeprom"
      autoload :I2C,        "#{__dir__}/api/i2c"
      autoload :Infrared,   "#{__dir__}/api/infrared"
      autoload :OneWire,    "#{__dir__}/api/one_wire"
      autoload :Servo,      "#{__dir__}/api/servo"
      autoload :SPIBitBang, "#{__dir__}/api/spi_bit_bang"
      autoload :SPI,        "#{__dir__}/api/spi"
      autoload :Tone,       "#{__dir__}/api/tone"
      autoload :LEDArray,   "#{__dir__}/api/led_array"
    end
  end
end
