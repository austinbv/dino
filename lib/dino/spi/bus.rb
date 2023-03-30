module Dino
  module SPI
    class Bus
      include Behaviors::MultiPin
      include Behaviors::BusController
      include Behaviors::Reader
    end
  end
end
