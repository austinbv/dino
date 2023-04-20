module Dino
  module Display
    class SSD1306 < I2C::Peripheral
      include Dino::Fonts
      
      # General commands.
      DISPLAY_OFF     = 0xAE
      DISPLAY_ON      = 0xAF
      SET_INVERT_OFF  = 0xA6
      SET_INVERT_ON   = 0xA7
      PIXELS_ALL_ON   = 0xA5
      PIXELS_FROM_RAM = 0xA4
      
      # Config commands. Following byte sets value.
      SET_CLOCK_DIV           = 0xD5
      SET_MULTIPLEX_RATIO     = 0xA8
      SET_DISPLAY_OFFSET      = 0xD3
      SET_CHARGE_PUMP         = 0x8D
      SET_COM_PIN_CONFIG      = 0xDA
      SET_CONTRAST            = 0x81
      SET_PRECHARGE_PERIOD    = 0xD9
      SET_VCOM_DESELECT_LEVEL = 0xDB

      # Config commands. OR with value then send.
      SET_START_LINE                = 0x40
      SET_SEGMENT_REMAP             = 0xA0
      SET_COM_OUTPUT_SCAN_DIRECTION = 0xC0
      
      # Page address mode commands.
      SET_PAGE_START         = 0xB0
      SET_COLUMN_START_LOWER = 0x00
      SET_COLUMN_START_UPPER = 0x10
      
      def after_initialize(options={})
        super(options)
        
        # Default to a 128x64 display.
        # Validate usable sizes here? 128x64, 128x32, 96x16, 64x48, 64x32.
        @columns = options[:columns] || 128
        @rows    = options[:rows]    || 64
        
        off
        
        # Everything except 96x16 size uses clock divider 0x80.
        command(SET_CLOCK_DIV)
        clock_divider = 0x80
        clock_divider = 0x60 if (@columns == 96 && @rows == 16)
        command(clock_divider)
        
        command(SET_MULTIPLEX_RATIO)
        command(@rows - 1)

        command(SET_DISPLAY_OFFSET)
        command(0x00)

        command(SET_START_LINE | 0x00)

        command(SET_CHARGE_PUMP)
        command(0x14) # 0x14 = internal, 0x10 = external

        command(SET_SEGMENT_REMAP | 0x01)
        
        # Scan pages from COM[N-1] to COM0
        command(SET_COM_OUTPUT_SCAN_DIRECTION | 0x08)
        
        # 128x32 and 96x16 sizes use com pin config 0x02
        command(SET_COM_PIN_CONFIG)
        com_pin_config = 0x12
        com_pin_config = 0x02 if (@columns == 96 && @rows == 16) || (@columns == 128 && @rows == 32)
        command(com_pin_config)

        command(SET_CONTRAST)
        command(0x9F)

        command(SET_PRECHARGE_PERIOD)
        command(0xF1) # 0xF1 = internal, 0x22 = external

        command(SET_VCOM_DESELECT_LEVEL)
        command(0x40)

        command(SET_INVERT_OFF)
      
        command(PIXELS_FROM_RAM)
        clear
        on
      end
      
      def off
        command(DISPLAY_OFF)
      end

      def on
        command(DISPLAY_ON)
      end

      def clear
        # Memory is arranged into pages 8 pixels high, mapping to rows.
        page_count = @rows / 8
        
        # For each page write an array of bytes (rows), @columns long, all zeroed.
        (0..page_count-1).each do |page|
          cursor(0,page)
          # This should come from a framebuffer eventually.
          data Array.new(@columns) {0}
        end
        
        cursor(0,0)
      end

      def cursor(x, y)
        command(SET_PAGE_START | y)
        
        # Column address is sent as two nibbles.
        column_start_lower_4 = x & 0x0F
        column_start_upper_4 = (x >> 4) & 0x0F
        
        command(SET_COLUMN_START_LOWER | column_start_lower_4)
        command(SET_COLUMN_START_UPPER | column_start_upper_4)
      end

      def print(str)
        str.split("").each do |char|
          print_char(char)
        end
      end

      def print_char(char)
        # 0th character in font is SPACE. Offset and limit to printable chars.
        index = char.ord - 32
        index = 0 if (index < 0 || index > 94)
        
        bitmap = FONT_6x8[index]
        data(bitmap)
      end

      def command(command=[])
        write [command].flatten.unshift(0x00)
      end

      def data(byte)
        write [byte].flatten.unshift(0x40)
      end
    end
  end
end
