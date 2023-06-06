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
Dino::Sensor::Temperature
Dino::Sensor::Humidity
Dino::Sensor::BME280
Dino::Sensor::BMP280
Dino::Sensor::DHT
Dino::Sensor::DS18B20
Dino::Sensor::HTU21D

# SPI
Dino::SPI::BaseRegister
Dino::SPI::BitBang
Dino::SPI::Bus
Dino::SPI::InputRegister
Dino::SPI::OutputRegister

# UART
Dino::UART::BitBang

# Helper module to redefine constants quietly.
module Constants
  def self.redefine(const, value, opts={})
    opts = {:on => self.class}.merge(opts)
    opts[:on].send(:remove_const, const) if self.class.const_defined?(const)
    opts[:on].const_set(const, value)
  end
  ACK = "SAMD_ZERO,0.13.0,528,1024"

  # Some test redefine RUBY_PLATFORM. Save the original to reset it.
  ORIGINAL_RUBY_PLATFORM = RUBY_PLATFORM
end

# Taken from: https://gist.github.com/moertel/11091573
def suppress_output
  begin
    original_stderr = $stderr.clone
    original_stdout = $stdout.clone
    if Constants::ORIGINAL_RUBY_PLATFORM.match(/mswin|mingw/i)
      $stderr.reopen('NUL:')
      $stdout.reopen('NUL:')
    else
      $stderr.reopen(File.new('/dev/null', 'w'))
      $stdout.reopen(File.new('/dev/null', 'w'))
    end
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

  WAITING_ON_READ_KEYS = [:read, :bus_controller, :board_proxy, :force_udpate]

  def component_exists_for_pin(pin)
    self.components.each do |component|
      return component if component.pin == pin
    end
    false
  end

  def waiting_on_read(component)
    WAITING_ON_READ_KEYS.each do |key|
      return true if component.callbacks[key]
    end
    false
  end

  #
  # Inject a message into the Board instance as if it were coming from the phsyical board.
  # Use this to mock input data for the blocking #read pattern in the Reader behavior.
  #
  def inject_read_for_pin(pin, message)
    Thread.new do
      # Wait for a component to be added.
      component = false
      while !component
        sleep(0.001)
        component = component_exists_for_pin(pin)
      end

      # Wait for the component to have a "WAITING_ON_READ" callback.
      sleep(0.001) while !component.callback_mutex
      sleep(0.001) while !component.callbacks
      sleep(0.001) while !waiting_on_read(component)

      # Then inject the message.
      @read_injection_mutex.synchronize do
        self.update("#{pin}:#{message}")
      end
    end
  end

  #
  # Inject a message into the Board instance as if it were coming from the phsyical board.
  # Use this to mock input data for the blocking #read pattern in the Reader behavior.
  #
  def inject_read_for_component(component, pin, message)
    Thread.new do
      # Wait for the component to have a "WAITING_ON_READ" callback.
      sleep(0.001) while !component.callback_mutex
      sleep(0.001) while !component.callbacks
      sleep(0.001) while !waiting_on_read(component)

      # Then inject the message.
      @read_injection_mutex.synchronize do
        self.update("#{pin}:#{message}")
      end
    end
  end
end

module TestPacker
  def pack(*args, **kwargs)
    Dino::Message.pack(*args, **kwargs)
  end
end

# Speed up one wire tests.
module Dino
  module OneWire
    class Bus
      def sleep(time)
        super(0.001)
      end
    end
  end
end
