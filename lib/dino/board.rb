module Dino
  class Board
    include API::Core
    include API::Servo
    include API::ShiftIO
    include API::SPI
    include API::Infrared
    include API::OneWire
    include API::Tone

    attr_reader :high, :low, :analog_high, :components, :analog_zero, :dac_zero

    def initialize(io, options={})
      @io, @components = io, []
      @analog_zero, @dac_zero = @io.handshake.to_s.split(",").map { |pin| pin.to_i }
      io.add_observer(self)
      self.analog_resolution = options[:bits] || 8
    end

    def analog_resolution=(value)
      @bits = value || 8
      write Dino::Message.encode(command: 96, value: @bits)
      @low  = 0
      @high = 1
      @analog_high = (2 ** @bits) - 1
    end

    def write(msg)
      @io.write(msg)
    end

    def update(pin, msg)
      @components.each do |part|
        part.update(msg) if pin.to_i == part.pin
      end
    end

    def add_component(component)
      @components << component
    end

    def remove_component(component)
      stop_listener(component.pin)
      @components.delete(component)
    end

    DIGITAL_REGEX = /\A\d+\z/i
    ANALOG_REGEX = /\A(a)\d+\z/i
    DAC_REGEX = /\A(dac)\d+\z/i

    def convert_pin(pin)
      pin = pin.to_s
      return pin.to_i             if pin.match(DIGITAL_REGEX)
      return analog_pin_to_i(pin) if pin.match(ANALOG_REGEX)
      return dac_pin_to_i(pin)    if pin.match(DAC_REGEX)
      raise "Incorrect pin format"
    end

    def analog_pin_to_i(pin)
      @analog_zero + pin.gsub(/\Aa/i, '').to_i
    end

    def dac_pin_to_i(pin)
      raise "The board did not specify any DAC pins" unless @dac_zero
      @dac_zero + pin.gsub(/\Adac/i, '').to_i
    end
  end
end
