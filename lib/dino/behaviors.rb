module Dino
  module Behaviors
    # Pin and component setup stuff
    autoload :Component,  "#{__dir__}/behaviors/component"
    autoload :SinglePin,  "#{__dir__}/behaviors/single_pin"
    autoload :InputPin,   "#{__dir__}/behaviors/input_pin"
    autoload :OutputPin,  "#{__dir__}/behaviors/output_pin"
    autoload :MultiPin,   "#{__dir__}/behaviors/multi_pin"
 
    # Subcomponent stuff
    autoload :Subcomponents,          "#{__dir__}/behaviors/subcomponents"
    autoload :BusController,          "#{__dir__}/behaviors/bus_controller"
    autoload :BusControllerAddressed, "#{__dir__}/behaviors/bus_controller_addressed"
    autoload :BusPeripheral,          "#{__dir__}/behaviors/bus_peripheral"
    autoload :BusPeripheralAddressed, "#{__dir__}/behaviors/bus_peripheral_addressed"
    autoload :BoardProxy,             "#{__dir__}/behaviors/board_proxy"

    # Async stuff
    autoload :Threaded,   "#{__dir__}/behaviors/threaded"
    autoload :Callbacks,  "#{__dir__}/behaviors/callbacks"
    autoload :Reader,     "#{__dir__}/behaviors/reader"
    autoload :Poller,     "#{__dir__}/behaviors/poller"
    autoload :Listener,   "#{__dir__}/behaviors/listener"
  end
end
