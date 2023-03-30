module Dino
  module Board
    module API
      autoload :Message,  "#{__dir__}/api/message"
      autoload :Helper,   "#{__dir__}/api/helper"
      autoload :Core,     "#{__dir__}/api/core"
      autoload :EEPROM,   "#{__dir__}/api/eeprom"
      autoload :I2C,      "#{__dir__}/api/i2c"
      autoload :Infrared, "#{__dir__}/api/infrared"
      autoload :OneWire,  "#{__dir__}/api/one_wire"
      autoload :Servo,    "#{__dir__}/api/servo"
      autoload :ShiftIO,  "#{__dir__}/api/shift_io"
      autoload :SPI,      "#{__dir__}/api/spi"
      autoload :Tone,     "#{__dir__}/api/tone"
      autoload :LEDArray, "#{__dir__}/api/led_array"
    end
  end
end