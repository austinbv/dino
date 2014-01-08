module Dino
  module Components
    class IrReceiver < Basic::DigitalInput
      alias :on_flash :on_low
    end
  end
end
