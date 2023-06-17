module Dino
  module Sensor
    autoload :Temperature, "#{__dir__}/sensor/virtual"
    autoload :Humidity,    "#{__dir__}/sensor/virtual"
    autoload :DHT,         "#{__dir__}/sensor/dht"
    autoload :DS18B20,     "#{__dir__}/sensor/ds18b20"
    autoload :BME280,      "#{__dir__}/sensor/bme280"
    autoload :HTU21D,      "#{__dir__}/sensor/htu21d"
  end
end
