module Dino
  module UART
    class Bitbang
      include Behaviors::MultiPin
      attr_accessor :baud

      COMMAND = 12

      def initialize_pins(options={})
        require_pin(:rx)
        require_pin(:tx)
      end

      def after_initialize(options={})
        self.baud = options[:baud]
        board.write Message.encode command: COMMAND, value: 0, aux_message: encoded_pins
        board.write Message.encode command: COMMAND, value: 1, aux_message: self.baud
      end
      
      def puts(string)
        board.write Message.encode command: COMMAND, value: 3, aux_message: string
      end

      private

      def encoded_pins
        [pins[:rx], pins[:tx]].compact.join(',')
      end
    end
  end
end
