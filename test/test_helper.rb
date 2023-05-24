require "minitest/autorun"

if RUBY_ENGINE == "ruby"
  require 'simplecov'
  SimpleCov.start do
    track_files "lib/**/*.rb"
    add_filter "test"
    add_filter "lib/dino_cli"
  end
end

require 'bundler/setup'
require 'dino'

# Touch each class to trigger auto load for simplecov.

# Analog IO
Dino::AnalogIO::ADS1118
Dino::AnalogIO::Input
Dino::AnalogIO::Output
Dino::AnalogIO::Potentiometer
Dino::AnalogIO::Sensor

# Behaviors
# Not needed, since every behavior will be included by at least one class.

# Board
# BoardMock inherits from Dino::Board

# Connection
Dino::Connection::Serial
Dino::Connection::TCP

# Digital IO
Dino::DigitalIO::Button
Dino::DigitalIO::Input
Dino::DigitalIO::Output
Dino::DigitalIO::Relay
Dino::DigitalIO::RotaryEncoder

# Display
Dino::Display::Canvas
Dino::Display::HD44780
Dino::Display::SSD1306

# EEPROM
Dino::EEPROM::BuiltIn

# I2C
Dino::I2C::Bus
Dino::I2C::Peripheral

# LED
Dino::LED::APA102
Dino::LED::Base
Dino::LED::RGB
Dino::LED::SevenSegment
Dino::LED::WS2812

# Motor
Dino::Motor::L298
Dino::Motor::Servo
Dino::Motor::Stepper

# OneWire
Dino::OneWire::Bus
Dino::OneWire::Peripheral
Dino::OneWire::Helper

# Pulse IO
Dino::PulseIO::Buzzer
Dino::PulseIO::IRTransmitter
Dino::PulseIO::PWMOutput

# RTC
Dino::RTC::DS3231

# Sensor
Dino::Sensor::BME280
Dino::Sensor::BMP280
Dino::Sensor::DHT
Dino::Sensor::DS18B20

# SPI
Dino::SPI::BaseRegister
Dino::SPI::BitBang
Dino::SPI::Bus
Dino::SPI::InputRegister
Dino::SPI::OutputRegister

# UART
Dino::UART::BitBang

# Nice little helper module to redefine constants quietly.
module Constants
  def self.redefine(const, value, opts={})
    opts = {:on => self.class}.merge(opts)
    opts[:on].send(:remove_const, const) if self.class.const_defined?(const)
    opts[:on].const_set(const, value)
  end

  ACK = "SAMD_ZERO,0.13.0,528,1024"
end

# Taken from: https://gist.github.com/moertel/11091573
def suppress_output
  begin
    original_stderr = $stderr.clone
    original_stdout = $stdout.clone
    $stderr.reopen(File.new('/dev/null', 'w'))
    $stdout.reopen(File.new('/dev/null', 'w'))
    retval = yield
  rescue Exception => e
    $stdout.reopen(original_stdout)
    $stderr.reopen(original_stderr)
    raise e
  ensure
    $stdout.reopen(original_stdout)
    $stderr.reopen(original_stderr)
  end
  retval
end

class ConnectionMock
  def add_observer(board); true; end
  def read; true; end
  def write(str); true; end
  def handshake
    Constants::ACK
  end
end

class BoardMock < Dino::Board
  def initialize
    super(ConnectionMock.new)
    @read_injection_mutex = Mutex.new
  end

  #
  # Inject a message into the Board instance as if it were coming from the phsyical board.
  # Use this to mock input data for the blocking #read pattern in the Reader behavior.
  #
  def inject_read(line, wait_for_callbacks = true)
    Thread.new do
      if wait_for_callbacks
        # Wait for a component to be added.
        sleep(0.005) while self.components.empty?
        component = self.components.first

        # Wait for the callback mutex to exist, then callbacks, then the read callback.
        sleep(0.05) while !component.callback_mutex
        sleep(0.05) while !component.callbacks
        sleep(0.05) while !component.callbacks[:read]
      end

      # Finally inject the message.
      @read_injection_mutex.synchronize do
        self.update(line)
      end
    end
  end
end

module TestPacker
  def pack(*args, **kwargs)
    Dino::Message.pack(*args, **kwargs)
  end
end
