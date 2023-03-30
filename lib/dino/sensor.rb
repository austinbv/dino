module Dino
  module Sensor
    autoload :DHT,      "#{__dir__}/sensor/dht"
    autoload :DS18B20,  "#{__dir__}/sensor/ds18b20"
    autoload :BME280,   "#{__dir__}/sensor/bme280"
  end
end
