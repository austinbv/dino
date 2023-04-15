module Dino
  module UART
    class Bitbang
      include Behaviors::MultiPin
      attr_accessor :baud

      COMMAND = 12
      # Initialize
      #
      # Dino::UART::Bitbang.new(
      #       board: board,
      #       pins: { rx:10, tx:11 },
      #       baud: 9600
      # )
      #
      def initialize_pins(options={})
        require_pin(:rx)
        require_pin(:tx)
      end

      def after_initialize(options={})
        self.baud = options[:baud]
        board.write Dino::Board::API::Message.encode command: COMMAND, value: 0, aux_message: encoded_pins
        board.write Dino::Board::API::Message.encode command: COMMAND, value: 1, aux_message: self.baud
      end
      
      # A useful pattern to be implemented if needed
      # LIBRARY_COMMANDS = {
      # }

      # LIBRARY_COMMANDS.each_pair do |command, command_id|
      #   define_method(command) do
      #     board.write Dino::Message.encode(command: 13, value: command_id)
      #   end
      # end

      def puts(string)
        board.write Dino::Board::API::Message.encode command: COMMAND, value: 3, aux_message: string
      end

      private

      def encoded_pins
        [pins[:rx], pins[:tx]].compact.join(',')
      end
    end
  end
end
