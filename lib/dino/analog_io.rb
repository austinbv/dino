module Dino
  module AnalogIO
    autoload :Input,          "#{__dir__}/analog_io/input"
    autoload :Output,         "#{__dir__}/analog_io/output"
    autoload :Potentiometer,  "#{__dir__}/analog_io/potentiometer"
    autoload :Sensor,         "#{__dir__}/analog_io/sensor"
  end
end
