module Dino
  module Sensor
    class Temperature
      include Behaviors::Poller

      def initialize(sensor)
        @sensor = sensor
        super
      end

      def _read
        @sensor.read_temperature
      end

      alias :celsius :state
      alias :to_i    :state

      def fahrenheit
        (celsius * 9 / 5) + 32
      end

      def kelvin
        celsius + 273.15
      end
    end

    class Humidity
      include Behaviors::Poller

      def initialize(sensor)
        @sensor = sensor
        super
      end

      def _read
        @sensor.read_humidity
      end

      alias :to_i :state
    end
  end
end
