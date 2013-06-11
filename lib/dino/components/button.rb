module Dino
  module Components
    class Button < Core::DigitalInput
      alias :down :on_low
      alias :up :on_high
    end
  end
end
