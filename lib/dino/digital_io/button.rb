module Dino
  module DigitalIO
    class Button < Input
      alias :down :on_low
      alias :up   :on_high
    end
  end
end
