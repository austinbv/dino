module Dino
  module AnalogIO
    autoload :Input,          "#{__dir__}/analog_io/input"
    autoload :Output,         "#{__dir__}/analog_io/output"
    autoload :Potentiometer,  "#{__dir__}/analog_io/potentiometer"
    autoload :Sensor,         "#{__dir__}/analog_io/sensor"
    autoload :ADS1118,        "#{__dir__}/analog_io/ads1118"
  end
end
