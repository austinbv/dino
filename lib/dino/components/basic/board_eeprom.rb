module Dino
  module Components
    module Basic
      class BoardEEPROM
        include Setup::Base
        include Mixins::Reader

        public :state=

        def after_initialize(options)
          super(options)
          self.state = Array.new(board.eeprom_length, nil)
          load
        end

        def load
          state.each_slice(128).with_index do |slice, index|
            read_using -> { board.eeprom_read(index * 128, slice.length) }
          end
        end

        def save
          @state_mutex.synchronize do
            @state.each_slice(128).with_index do |slice, index|
              board.eeprom_write(index * 128, slice)
            end
          end
          load
        end

        def pre_callback_filter(message)
          address = message.split("-", 2)[0].to_i
          bytes = message.split("-", 2)[1].split(",").map(&:to_i)
          {address: address, data: bytes}
        end

        def update_self(hash)
          self.state[hash[:address], hash[:data].length] = hash[:data]
        end

        def pin
          "EE"
        end
      end
    end
  end
end
