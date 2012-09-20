module Dino
  class Sensor
    attr_reader :pin

    def initialize(hash)
      @pin, @board = hash[:pin], hash[:board]
      raise 'a board and a pin are required for an button' if @board.nil? || @pin.nil?

      @data_callbacks = []
      @board.add_analog_hardware(self)
      @board.start_read
    end

    def when_data_received(callback)
      @data_callbacks << callback
    end

    def update(data)
      @data_callbacks.each do |callback|
        callback.call(data)
      end
    end
  end
end