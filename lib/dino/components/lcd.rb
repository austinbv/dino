module Dino
  module Components
    class LCD < BaseComponent

      # Initialize in 4 bits mode
      #
      # Dino::Componentes::LCD.new(
      #       board: board,
      #       pins: { rs: 12, enable: 11, d4: 4, d5: 5, d6: 6, d7: 7 }
      # )
      #
      # Initialize in 8 bits mode
      #
      # Dino::Componentes::LCD.new(
      #       board: board,
      #       pins: { rs: 12, enable: 11, d0: 0, d1: 1, d2: 2, d3: 3, d4: 4, d5: 5, d6: 6, d7: 7 }
      # )
      #
      def after_initialize(options)
        board.write Dino::Message.encode command: 10, value: 0, aux_message: encoded_pins
      end

      def begin(cols, rows)
        board.write Dino::Message.encode command: 10, value: 1, aux_message: "#{cols},#{rows}"
        sleep 2
      end

      def clear
        board.write Dino::Message.encode command: 10, value: 2
      end

      def home
        board.write Dino::Message.encode command: 10, value: 3
      end

      def set_cursor(col, row)
        board.write Dino::Message.encode command: 10, value: 4, aux_message: "#{col},#{row}"
      end

      def puts(string)
        board.write Dino::Message.encode command: 10, value: 5, aux_message: string
      end

      def show_cursor
        board.write Dino::Message.encode command: 10, value: 6
      end

      def hide_cursor
        board.write Dino::Message.encode command: 10, value: 7
      end

      def blink
        board.write Dino::Message.encode command: 10, value: 8
      end

      def no_blink
        board.write Dino::Message.encode command: 10, value: 9
      end

      def on
        board.write Dino::Message.encode command: 10, value: 10
      end

      def off
        board.write Dino::Message.encode command: 10, value: 11
      end

      def scroll_left
        board.write Dino::Message.encode command: 10, value: 12
      end

      def scroll_right
        board.write Dino::Message.encode command: 10, value: 13
      end

      def enable_autoscroll
        board.write Dino::Message.encode command: 10, value: 14
      end

      def disable_autoscroll
        board.write Dino::Message.encode command: 10, value: 15
      end

      def left_to_right
        board.write Dino::Message.encode command: 10, value: 16
      end

      def right_to_left
        board.write Dino::Message.encode command: 10, value: 17
      end

      private

      def encoded_pins
        encoded = [pins[:rs], pins[:enable], pins[:d0],
                   pins[:d1], pins[:d2], pins[:d3], pins[:d4],
                   pins[:d5], pins[:d6], pins[:d7]]
        encoded.compact.join(',')
      end
    end
  end
end
