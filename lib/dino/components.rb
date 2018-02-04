module Dino
  module Components
    require 'dino/components/setup'
    require 'dino/components/mixins'
    require 'dino/components/basic'
    require 'dino/components/register'
    autoload :Led,              'dino/components/led'
    autoload :Button,           'dino/components/button'
    autoload :Sensor,           'dino/components/sensor'
    autoload :RgbLed,           'dino/components/rgb_led'
    autoload :Servo,            'dino/components/servo'
    autoload :SSD,              'dino/components/ssd'
    autoload :Stepper,          'dino/components/stepper'
    autoload :IrReceiver,       'dino/components/ir_receiver'
    autoload :LCD,              'dino/components/lcd'
    autoload :Relay,            'dino/components/relay'
    autoload :SoftwareSerial,   'dino/components/softserial'
    autoload :DHT,              'dino/components/dht'
    autoload :IREmitter,        'dino/components/ir_emitter'
    autoload :Piezo,            'dino/components/piezo'
    autoload :RotaryEncoder,    'dino/components/rotary_encoder'
    autoload :OneWire,          'dino/components/onewire'
  end
end
