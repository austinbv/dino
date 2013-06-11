module Dino
  module Components
    class IrReceiver < Core::DigitalInput
      alias :flash :on_low

      def update(data)
        return if data.to_i == HIGH
        super data
      end
    end
  end
end
