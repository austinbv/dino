Thread.abort_on_exception = true

module Dino
  def self.root
    File.expand_path '../..', __FILE__
  end
end

# Board stuff.
require_relative 'dino/version'
require_relative 'dino/message'
require_relative 'dino/connection'
require_relative 'dino/board'

# Component support stuff.
require_relative 'dino/behaviors'
require_relative 'dino/fonts'

# Basic IO components.
require_relative 'dino/digital_io'
require_relative 'dino/analog_io'
require_relative 'dino/pulse_io'

# Buses and interfaces.
require_relative 'dino/uart'
require_relative 'dino/spi'
require_relative 'dino/i2c'
require_relative 'dino/one_wire'

# Everything else.
require_relative 'dino/display'
require_relative 'dino/eeprom'
require_relative 'dino/led'
require_relative 'dino/motor'
require_relative 'dino/rtc'
require_relative 'dino/sensor'
