module Dino
  module Components
    module Mixins
      module BusSlave
        include Setup::Base

        attr_reader :address
        alias  :bus :board

        def before_initialize(options={})
          options[:board] ||= options[:bus]
          
          unless options[:address]
            raise ArgumentError,
                  'missing Slave device address; try Bus#search first'
          end
          @address = options[:address]
          
          super(options)
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
