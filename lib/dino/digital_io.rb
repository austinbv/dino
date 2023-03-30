module Dino
  module DigitalIO
    autoload :Input,          "#{__dir__}/digital_io/input"
    autoload :Output,         "#{__dir__}/digital_io/output"
    autoload :Button,         "#{__dir__}/digital_io/button"
    autoload :Relay,          "#{__dir__}/digital_io/relay"
    autoload :RotaryEncoder,  "#{__dir__}/digital_io/rotary_encoder"
  end
end
