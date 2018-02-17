module Dino
  module Components
    module Mixins
      module BusSlave
        include Setup::Base

        attr_reader :address
        alias  :bus :board

        def initialize(options={})
          options[:board] ||= options[:bus]
          super(options)
        end

        def after_initialize(options={})
          super(options)

          unless options[:address]
            raise ArgumentError,
                  'missing Slave device address; try Bus#search first'
          end
          @address = options[:address]
        end

        def atomically(&block)
          bus.mutex.synchronize do
            block.call
          end
        end
      end
    end
  end
end
