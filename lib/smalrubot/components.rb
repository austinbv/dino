module Smalrubot
  module Components
    require 'smalrubot/components/base_component'
    autoload :Led,        'smalrubot/components/led'
    autoload :Button,     'smalrubot/components/button'
    autoload :Sensor,     'smalrubot/components/sensor'
    autoload :RgbLed,     'smalrubot/components/rgb_led'
    autoload :Servo,      'smalrubot/components/servo'
    autoload :Stepper,    'smalrubot/components/stepper'
    autoload :IrReceiver, 'smalrubot/components/ir_receiver'
  end
end
