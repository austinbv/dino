module Dino
  module Components
    class LCD < BaseComponent

      # Overwriting initialize, we don't need to specify pins this time
      def initialize(options={})
        self.board = options[:board]
        raise 'board is required for a display' if self.board.nil?
        after_initialize(options)
      end

      def begin(cols, rows)
        cols = normalize(cols, 2)
        rows = normalize(rows, 2)
        board.write("0501#{cols}#{rows}")
        sleep 2
      end

      def clear
        board.write('0502')
      end

      def home
        board.write('0503')
      end

      def set_cursor(col, row)
        col = normalize(col, 2)
        row = normalize(row, 2)
        board.write("0504#{col}#{row}")
      end

      def write(value)
        value = normalize(value, 3)
        board.write("0505#{value}")
      end

      def puts(string)
        string.bytes.each do |byte|
          write(byte)
        end
      end

      def show_cursor
        board.write('0506')
      end

      def hide_cursor
        board.write('0507')
      end

      def blink
        board.write('0508')
      end

      def no_blink
        board.write('0509')
      end

      def on
        board.write('0510')
      end

      def off
        board.write('0511')
      end

      def scroll_left
        board.write('0512')
      end

      def scroll_right
        board.write('0513')
      end

      def enable_autoscroll
        board.write('0514')
      end

      def disable_autoscroll
        board.write('0515')
      end

      def left_to_right
        board.write('0516')
      end

      def right_to_left
        board.write('0517')
      end

      private

      def normalize(value, spaces)
        value.to_s.rjust(spaces, '0')
      end
    end
  end
end

