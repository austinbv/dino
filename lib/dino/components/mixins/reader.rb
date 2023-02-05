module Dino
  module Components
    module Mixins
      module Reader
        include Callbacks

        #
        # Defalt behavior for #read is to delegate to #_read.
        # Define #_read in including classes.
        #
        def read(*args, &block)
          read_using(self.method(:_read), *args, &block)
        end

        #
        # Delegate reading to another method that sends a command to the board. 
        # Accepts blocks as one-time callbacks stored in the :read key.
        # Blocks until a value is recieved from the board.
        # Returns the value after #pre_callback_filter runs on it.
        #
        # Give procs as methods to build more complex functionality for buses.
        #
        def read_using(method, *args, &block)
          add_callback(:read, &block) if block_given?

          value = nil
          add_callback(:read) do |filtered_data|
            value = filtered_data
          end
          
          method.call(*args)
          block_until_read

          value
        end
        
        def block_until_read
          loop do
            break if !@callbacks[:read]
            # EEPROM read won't work without sleeping here. Not sure why.
            sleep 0.001
          end
        end

        def _read
          raise NotImplementedError
            .new("#{self.class.name}#_read is not defined.")
        end
      end
    end
  end
end
