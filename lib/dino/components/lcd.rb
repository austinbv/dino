module Dino
  module Components
    class LCD < Core::MultiPin

      # Initialize in 4 bits mode
      #
      # Dino::Componentes::LCD.new(
      #       board: board,
      #       pins: { rs: 12, enable: 11, d4: 4, d5: 5, d6: 6, d7: 7 },
      #       cols: 16,
      #       rows: 2
      # )
      #
      # Initialize in 8 bits mode
      #
      # Dino::Componentes::LCD.new(
      #       board: board,
      #       pins: { rs: 12, enable: 11, d0: 0, d1: 1, d2: 2, d3: 3, d4: 4, d5: 5, d6: 6, d7: 7 },
      #       cols: 16,
      #       rows: 2
      # )
      #
      def after_initialize(options)
        board.write Dino::Message.encode command: 10, value: 0, aux_message: encoded_pins
        @cols, @rows = options[:cols], options[:rows]
        board.write Dino::Message.encode command: 10, value: 1, aux_message: "#{@cols},#{@rows}"
      end

      LIBRARY_COMMANDS = {
        clear:              '2',
        home:               '3',
        show_cursor:        '6',
        hide_cursor:        '7',
        blink:              '8',
        no_blink:           '9',
        on:                '10',
        off:               '11',
        scroll_left:       '12',
        scroll_right:      '13',
        enable_autoscroll: '14',
        disable_autoscroll:'15',
        left_to_right:     '16',
        right_to_left:     '17'
      }

      LIBRARY_COMMANDS.each_pair do |command, command_id|
        define_method(command) do
          board.write Dino::Message.encode(command: 10, value: command_id)
        end
      end

      def set_cursor(col, row)
        board.write Dino::Message.encode command: 10, value: 4, aux_message: "#{col},#{row}"
      end

      def puts(string)
        board.write Dino::Message.encode command: 10, value: 5, aux_message: string
      end

      private

      def encoded_pins
        [pins[:rs], pins[:enable], pins[:d0],
         pins[:d1], pins[:d2], pins[:d3], pins[:d4],
         pins[:d5], pins[:d6], pins[:d7]].compact.join(',')
      end
    end
  end
end
