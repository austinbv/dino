module Dino
  module I2C
    class Bus
      include Behaviors::SinglePin
      include Behaviors::BusController
      include Behaviors::Reader

      attr_reader :found_devices

      def after_initialize(options={})
        super(options)
        @found_devices = []
        bubble_callbacks
      end

      def search
        addresses = read_using -> { board.i2c_search }
        if addresses
          @found_devices = addresses.split(":").map(&:to_i)
        end
      end

      def write(address, bytes=[], **kwargs)
        board.i2c_write(address, [bytes].flatten, **kwargs)
      end

      def _read(address, register=nil, num_bytes=1, **kwargs)
        board.i2c_read(address, register, num_bytes, **kwargs)
      end

      def bubble_callbacks
        add_callback(:bus_master) do |str|
          if str && str.match(/\A\d+-/)
            address, data = str.split("-", 2)
            address = address.to_i
            data = data.split(",").map(&:to_i)
            update_component(address, data)
          end
        end
      end

      def update_component(address, data)
        components.each do |component|
          if component.address == address
            component.update(data)
          end
        end
      end
    end
  end
end
