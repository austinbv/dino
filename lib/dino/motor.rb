module Dino
  module Motor
    autoload :Servo,    "#{__dir__}/motor/servo"
    autoload :Stepper,  "#{__dir__}/motor/stepper"
    autoload :L298,     "#{__dir__}/motor/l298"
  end
end
