module Dino
  module Components
    module Register
      class Select
        #
        # Register select is an active-low output pin, used to choose which
        # register on a bus we're accessing. For input registers, the board
        # sends readings prefixed with the register select pin number, since
        # each register uses a unique select pin, while clock and data are shared.
        #
        # There is no need to write this pin directly, but it must be in output
        # mode, and must follow the callback pattern to receive updates.
        #
        include Setup::SinglePin
        include Setup::Output
        include Mixins::Callbacks

        def initialize_pins(options={})
          super(options) if defined?(super)
          board.start_read
        end
      end
    end
  end
end
