module Dino
  module Components
    class Led < Core::BaseOutput
      alias :on  :high
      alias :off :low
    end
  end
end
