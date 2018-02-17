module Dino
  module Components
    module Mixins
      module Reader
        include Callbacks

        def read_using(method, &block)
          add_callback(:read, &block) if block_given?

          # Block and catches read value for return, AFTER the pre-filter.
          value = nil
          add_callback(:read) { |data| value = data }

          method.call
          block_until_read

          value
        end

        def read(&block)
          read_using(self.method(:_read), &block)
        end

        def block_until_read
          loop { break if !@callbacks[:read] }
        end

        def _read
          raise NotImplementedError
            .new("#{self.class.name}#_read is not defined.")
        end
      end
    end
  end
end
