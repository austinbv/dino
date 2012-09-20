module Dino
  class Button
    UP = "01"
    DOWN = "00"
    attr_reader :pin

    def initialize(hash)
      @pin, @board = hash[:pin], hash[:board]
      raise 'a board and a pin are required for an button' if @board.nil? || @pin.nil?

[      @down_callbacks, @up_callbacks, @state = [], [], UP
]
      @board.add_digital_hardware(self)
      @board.start_read
    end

    def down(callback)
      @down_callbacks << callback
    end

    def up(callback)
      @up_callbacks << callback
    end

    def update(data)
      return if data == @state
      @state = data

      case data
        when UP
          button_up
        when DOWN
          button_down
        else
          return
      end
    end

    private

    def button_up
      @up_callbacks.each do |callback|
        callback.call
      end
    end

    def button_down
      @down_callbacks.each do |callback|
        callback.call
      end
    end
  end
end