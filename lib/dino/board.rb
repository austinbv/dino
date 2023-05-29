# Require all files in board folder relative to this file.
Dir["#{Dino.root}/lib/dino/board/*.rb"].each {|file| require file }

module Dino
  class Board
    attr_reader :board_name, :version, :aux_limit, :eeprom_length
    attr_reader :low, :high, :analog_write_high, :analog_read_high

    def initialize(io, options={})
      # Connect the IO, and get the ACK.
      @io = io
      ack = io.handshake
      @name, @version, @aux_limit, @eeprom_length = ack.split(",")

      # Parse map, version and eeprom_legnth.
      @name          = nil if @name.empty?
      @version       = nil if @version.empty?
      @eeprom_length = @eeprom_length.to_i

      # Leave room for null termination of aux messages.
      @aux_limit = @aux_limit.to_i - 1

      # Load the board map.
      @map = load_map(@name)

      # Allow the IO to call #update on the board when messages received.
      io.add_observer(self)
      
      # Set digital and analog IO levels.
      @low  = 0
      @high = 1
      self.analog_write_resolution = options[:write_bits] || 8
      self.analog_read_resolution = options[:read_bits] || 10
    end
    
    def finish_write
      sleep 0.001 while @io.writing?
      write "\n91\n"
      sleep 0.001 while @io.writing?
    end
          
    def analog_write_resolution=(value)
      set_analog_write_resolution(value)
      @write_bits = value
      @analog_write_high = (2 ** @write_bits) - 1
    end
    
    def analog_read_resolution=(value)
      set_analog_read_resolution(value)
      @read_bits = value
      @analog_read_high = (2 ** @read_bits) - 1
    end
    
    def analog_write_resolution
      @write_bits
    end

    def analog_read_resolution
      @read_bits
    end
    
    alias :pwm_high :analog_write_high
    alias :dac_high :analog_write_high
    alias :adc_high :analog_read_high
    
    def write(msg)
      @io.write(msg)
    end

    #
    # Use Board#write_and_halt to call C++ board functions that disable interrupts
    # for a long time. "Long" being more than 1 serial character (~85us for 115200 baud).
    #
    # The "halt" part tells the TxRx to halt transmission to the board after this message.
    # Since it expects interrupts to be disabled, any data sent could be lost.
    #  
    # When the board function has re-enabled interrupts, it should call sendReady(). That
    # signal is read by the TxRx, telling it to resume transmisison.
    #
    def write_and_halt(msg)
      @io.write(msg, true)
    end

    #
    # Use standard Subcomponents behavior.
    #
    include Behaviors::Subcomponents

    def update(line)
      pin, message = line.split(":", 2)
      pin = pin.to_i
      if single_pin_components[pin]
        single_pin_components[pin].update(message)
      end
    end

    #
    # Component generating convenience methods. TODO: add more!
    #
    def eeprom
      @eeprom ||= EEPROM::BuiltIn.new(board: self)
    end
  end
end
