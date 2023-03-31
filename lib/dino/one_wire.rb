module Dino
  module OneWire
    autoload :Constants,      "#{__dir__}/one_wire/constants"
    autoload :Helper,         "#{__dir__}/one_wire/helper"
    autoload :BusEnumeration, "#{__dir__}/one_wire/bus_enumeration"
    autoload :Bus,            "#{__dir__}/one_wire/bus"
    autoload :Peripheral,     "#{__dir__}/one_wire/peripheral"
  end
end
