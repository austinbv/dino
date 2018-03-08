module Dino
  module Components
    module I2C
      class Bus
        include Setup::SinglePin
        include Mixins::BusMaster
        include Mixins::Reader

        attr_reader :found_devices

        def after_initialize(options={})
          super(options)
          bubble_callbacks
        end

        def search
          addresses = read_using -> { board.i2c_search }
          @found_devices = addresses.split(":").map(&:to_i)
        end

        def write(address, bytes=[], options={})
          board.i2c_write(address, [bytes].flatten, options)
        end

        def read(*args)
          read_using -> { _read(*args) }
        end

        def _read(address, register, num_bytes=1, options={})
          board.i2c_read(address, register, num_bytes, options)
        end

        def bubble_callbacks
          add_callback(:bus_master) do |str|
            if str.match(/d*-/)
              address, data = str.split("-", 2)
              address = address.to_i
              data = data.split(",").map(&:to_i)
              update_component({address: address, data: data})
            end
          end
        end

        def update_component(hash)
          components.each do |component|
            if component.address == hash[:address]
              component.update(hash[:data])
            end
          end
        end
      end
    end
  end
end
