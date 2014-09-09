module Dino
  module Components
    class Stepper
      include Setup::MultiPin 

      proxy_pins  step:      Basic::DigitalOutput,
                  direction: Basic::DigitalOutput

      proxy_pins  ms1:       Basic::DigitalOutput,
                  ms2:       Basic::DigitalOutput,
                  enable:    Basic::DigitalOutput,
                  sleep:     Basic::DigitalOutput,
                  optional: true

      def after_initialize(options={})
        wake; on; divider = 8
      end

      def sleep_mode
        sleep.low if pins[:sleep]
      end

      def wake
        sleep.high if pins[:sleep]
      end

      def off
        enable.high if pins[:enable]
      end

      def on
        enable.low if pins[:enable]
      end

      def divider=(steps)
        return unless (ms1 && ms2)
        case steps.to_i
        when 1
          ms1.low; ms2.low
        when 2
          ms1.high; ms2.low
        when 4
          ms1.low; ms2.high
        when 8
          ms1.high; ms2.high
        else
          return
        end
        @divider = steps
      end
      attr_reader :divider

      def step_cc
        direction.high unless direction.high?
        step.high
        step.low
      end

      def step_cw
        direction.low unless direction.low?
        step.high
        step.low
      end
    end
  end
end
