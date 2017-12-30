module Dino
  module Components
    module Mixins
      module Reader
        include Callbacks

        def read(&block)
          add_callback(:read, &block) if block_given?
          _read
          loop { break if !@callbacks[:read] }
        end

        #
        # Including component should define this to perform a single read on the board.
        #
        def _read; end
      end
    end
  end
end
