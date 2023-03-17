#
# Ruby implementation of Hitach HD44780 LCD support.
# Based on the Adafruit_LiquidCrystal library:
# https://github.com/adafruit/Adafruit_LiquidCrystal
#
module Dino
  module Components
    class HD44780
      include Setup::MultiPin
      
      # Commands
      LCD_CLEARDISPLAY   = 0x01
      LCD_RETURNHOME     = 0x02
      LCD_ENTRYMODESET   = 0x04
      LCD_DISPLAYCONTROL = 0x08
      LCD_CURSORSHIFT    = 0x10
      LCD_FUNCTIONSET    = 0x20
      LCD_SETCGRAMADDR   = 0x40
      LCD_SETDDRAMADDR   = 0x80
      
      # Flags for display entry mode
      LCD_ENTRYRIGHT          = 0x00
      LCD_ENTRYLEFT           = 0x02
      LCD_ENTRYSHIFTINCREMENT = 0x01
      LCD_ENTRYSHIFTDECREMENT = 0x00
      
      # Flags for display on/off control
      LCD_DISPLAYON  = 0x04
      LCD_DISPLAYOFF = 0x00
      LCD_CURSORON   = 0x02
      LCD_CURSOROFF  = 0x00
      LCD_BLINKON    = 0x01
      LCD_BLINKOFF   = 0x00
      
      # Flags for display/cursor shift
      LCD_DISPLAYMOVE = 0x08
      LCD_CURSORMOVE  = 0x00
      LCD_MOVERIGHT   = 0x04
      LCD_MOVELEFT    = 0x00
      
      # Flags for function set
      LCD_8BITMODE = 0x10
      LCD_4BITMODE = 0x00
      LCD_2LINE    = 0x08
      LCD_1LINE    = 0x00
      LCD_5x10DOTS = 0x04
      LCD_5x8DOTS  = 0x00

      def initialize_pins(options={})
        proxy_pin :rs,     Basic::DigitalOutput
        proxy_pin :enable, Basic::DigitalOutput
        proxy_pin :d4,     Basic::DigitalOutput
        proxy_pin :d5,     Basic::DigitalOutput
        proxy_pin :d6,     Basic::DigitalOutput
        proxy_pin :d7,     Basic::DigitalOutput
        
        # If any of d0-d3 was given, make them all non-optional.
        lower_bits_optional = (self.pins.keys & [:d0, :d1, :d2, :d3]).empty?
        proxy_pin :d0,     Basic::DigitalOutput, optional: lower_bits_optional
        proxy_pin :d1,     Basic::DigitalOutput, optional: lower_bits_optional
        proxy_pin :d2,     Basic::DigitalOutput, optional: lower_bits_optional
        proxy_pin :d3,     Basic::DigitalOutput, optional: lower_bits_optional
        
        # RW pin is mostly hard-wired to ground, but can given.
        proxy_pin :rw,     Basic::DigitalOutput, optional: true
      end

      def after_initialize(options={})
        super(options) if defined?(super)
        
        # Default to 16x2 display if no options given.
        @columns = options[:columns] || 16
        @rows    = options[:rows]    || 2
        
        # Create a fuction set byte to set up the LCD. These defaults equal 0x00.
        @function = LCD_4BITMODE | LCD_1LINE | LCD_5x8DOTS

        # Set 8-bit mode in the mask if d0-d3 are present.
        if (d0 && d1 && d2 && d3)
          @bits          = 8
          @function |= LCD_8BITMODE
        else
          @bits = 4
        end

        # Set 2 line (row) mode if needed.
        @function |= LCD_2LINE if (@rows > 1)

        # Some 1 line displays can use a 5x10 font.
        @function |= LCD_5x10DOTS if options[:tall_font] && (@rows == 1)
        
        # Offset memory address when moving cursor.
        # Row 2 always starts at memory address 0x40.
        # For 4 line LCDs:
        #   Row 3 is immediately after row 1, +16 or 20 bytes, depending on columns.
        #   Row 4 is immediately after row 2, +16 or 20 bytes, depending on columns.
        @row_offsets = [0x00, 0x40, 0x00+@columns, 0x40+@columns]
        
        # Wait 50ms for power to be > 2.7V, then pull everything low.
        micro_delay(50000)
        enable.low; rs.low; rw.low if rw

        # Start in 4-bit mode.
        if @bits == 4
          # Keep setting 8-bit mode until ready.
          command(0x03); micro_delay(4500)
          command(0x03); micro_delay(4500)
          command(0x03); micro_delay(150)
          
          # Set 4-bit mode.
          command(0x02)
          
        # Or start in 8 bit mode.
        else
          command(LCD_FUNCTIONSET | @function)
          micro_delay(4500)
          command(LCD_FUNCTIONSET | @function)
          micro_delay(150)
          command(LCD_FUNCTIONSET | @function)
        end
        
        # Set functions (lines, font size, etc.).
        command(LCD_FUNCTIONSET | @function)

        # Start with cursor off and no cursor blink.
        @control = LCD_DISPLAYON | LCD_CURSOROFF | LCD_BLINKOFF
        display_on
        clear
        
        # Set entry mode defaults.
        @mode = LCD_ENTRYLEFT | LCD_ENTRYSHIFTDECREMENT
        command(LCD_ENTRYMODESET | @mode)
        
        # Need this small delay to avoid garbage data on startup.
        sleep 0.05
      end

      def clear
        command(LCD_CLEARDISPLAY)
        micro_delay(2000)
      end

      def home
        command(LCD_RETURNHOME)
        micro_delay(2000)
      end

      def set_cursor(col, row)
        # Limit to the highest row, 0 indexed.
        row = (@rows - 1) if row > (@rows - 1)
        
        # 
        command(LCD_SETDDRAMADDR | (col + @row_offsets[row]))
      end
      alias :move_to :set_cursor
      
      def print(text)
        text.each_byte { |b| write b }
      end
      
      #
      # Create a #key_on and #key_off method for each feature in this hash,
      # using the constant in the value to send a control signal.
      #
      # Eg. #display_on and #display_off.
      #
      CONTROL_TOGGLES = {
        display: LCD_DISPLAYON,
        cursor: LCD_CURSORON,
        blink: LCD_BLINKON,
      }
      CONTROL_TOGGLES.each_key do |key|
        define_method (key.to_s << "_off").to_sym do
          command LCD_DISPLAYCONTROL | (@control &= ~CONTROL_TOGGLES[key])
        end
        define_method (key.to_s << "_on") do
          command LCD_DISPLAYCONTROL | (@control |= CONTROL_TOGGLES[key])
        end
      end
      
      def left_to_right
        @mode |= LCD_ENTRYLEFT
        command(LCD_ENTRYMODESET | @mode)
      end
      
      def right_to_left
        @mode &= ~LCD_ENTRYLEFT
        command(LCD_ENTRYMODESET | @mode)
      end
      
      def scroll_left
        command(LCD_CURSORSHIFT | LCD_DISPLAYMOVE | LCD_MOVELEFT)
      end
      
      def scroll_right
        command(LCD_CURSORSHIFT | LCD_DISPLAYMOVE | LCD_MOVERIGHT)
      end
      
      def autoscroll_on
        @mode |= LCD_ENTRYSHIFTINCREMENT;
        command(LCD_ENTRYMODESET | @mode);
      end
      
      def autoscroll_off
        @mode &= ~LCD_ENTRYSHIFTINCREMENT;
        command(LCD_ENTRYMODESET | @mode);
      end
      
      # Define custom characters as bit maps.
      def create_char
      end
      
      def command(byte)
        send(byte, board.low)
      end
      
      def write(byte);
        send(byte, board.high)
      end

      def send(byte, rs_level)
        # RS pin goes low to send commands, high to send data.
        rs.write(rs_level) unless rs.state == rs_level
        rw.low if rw
        
        # Get the byte as a string of 0s and 1s, LSBFIRST.
        bits_from_byte = byte.to_s(2).rjust(8, "0").reverse
        
        # Write bits depending on connection.
        @bits == 8 ? write8(bits_from_byte) : write4(bits_from_byte)
      end
      
      def write4(bits)
        d4.write bits[4]
        d5.write bits[5]
        d6.write bits[6]
        d7.write bits[7]
        pulse_enable
        d4.write bits[0]
        d5.write bits[1]
        d6.write bits[2]
        d7.write bits[3]
        pulse_enable
      end

      def write8(bits)
        d0.write bits[0]
        d1.write bits[1]
        d2.write bits[2]
        d3.write bits[3]
        d4.write bits[4]
        d5.write bits[5]
        d6.write bits[6]
        d7.write bits[7]
        pulse_enable
      end

      def pulse_enable
        enable.low
        micro_delay 1
        enable.high
        micro_delay 1
        enable.low
        micro_delay 100
      end
    end
  end
end
