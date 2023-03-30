module Dino
  module I2C
    autoload :Bus,        "#{__dir__}/i2c/bus"
    autoload :Peripheral, "#{__dir__}/i2c/peripheral"
  end
end
