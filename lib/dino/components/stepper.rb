module Dino
  module Components
    class Stepper < Core::MultiPin
      def after_initialize(options={})
        proxies step:      Core::BaseOutput,
                direction: Core::BaseOutput
      end

      def step_cc
        direction.high
        step.high
        step.low
      end

      def step_cw
        direction.low
        step.high
        step.low
      end
    end
  end
end
