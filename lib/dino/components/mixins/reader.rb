module Dino
  module Components
    module Mixins
      module Reader
        include Callbacks

        def read(*args, &block)
          add_callback(:read, &block) if block_given?

          value = nil
          add_callback(:read) { |data| value = data }

          _read(*args)
          loop { break if !@callbacks[:read] }

          value
        end

        def _read
          raise NotImplementedError
            .new("#{self.class.name}#_read is not defined.")
        end
      end
    end
  end
end
