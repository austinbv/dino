module Dino
  class Button
    UP = "01"
    DOWN = "00"

    def initialize(hash)
      @pin, @board = hash[:pin], hash[:board]
      raise 'a board and a pin are required for an button' if @board.nil? || @pin.nil?

      @board.add_observer(self)
      @board.set_pin_mode(@pin, :in)
      @down_callbacks = []
      @up_callbacks = []
      @state = UP
      start_read
    end

    def down(callback)
      @down_callbacks << callback
    end

    def start_read
      @board.start_read
      @read = Thread.new do
        loop do
          @board.digital_read(13)
          sleep 0.005
        end
      end
    end

    def close_read
      Thread.kill(@read)
      @read = nil
      @board.stop_read
    end

    def up(callback)
      @up_callbacks << callback
    end

    def update(pin, data)
      return unless pin == @pin.to_s
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