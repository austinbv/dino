module Dino
  module Behaviors
    module Threaded
      attr_reader :thread, :interrupts_enabled

      module ClassMethods
        def interrupt_with(*args)
          interrupts = self.class_eval('@@interrupts') rescue []
          interrupts = (interrupts + args).uniq
          self.class_variable_set(:@@interrupts, interrupts)
        end
      end

      def self.included(base)
        base.extend ClassMethods
      end

      def threaded(&block)
        stop_thread
        enable_interrupts unless interrupts_enabled
        @thread = Thread.new(&block)
      end

      def threaded_loop(&block)
        threaded do
          loop(&block)
        end
      end

      def stop_thread
        @thread.kill if @thread
      end

      def enable_interrupts
        interrupts = self.class.class_eval('@@interrupts') rescue []
        interrupts.each do |method_name|
          standard_method = self.method(method_name)

          singleton_class.send(:define_method, method_name) do |*args|
            stop_thread unless (Thread.current == @thread)
            standard_method.call(*args)
          end
        end

        @interrupts_enabled = true
      end
    end
  end
end
