module Smalrubot
  module Components
    require 'smalrubot/components/base_component'
    autoload :Led,        'smalrubot/components/led'
    autoload :Sensor,     'smalrubot/components/sensor'
    autoload :Servo,      'smalrubot/components/servo'
  end
end
