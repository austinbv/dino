module Dino
  module PulseIO
    autoload :PWMOutput,      "#{__dir__}/pulse_io/pwm_output"
    autoload :Buzzer,         "#{__dir__}/pulse_io/buzzer"
    autoload :IRTransmitter,  "#{__dir__}/pulse_io/ir_transmitter"
  end
end
