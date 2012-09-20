require 'spec_helper'

module Dino
  describe RgbLed do
    describe '#initialize' do
      it 'should raise if it does not receive a pin' do
        expect {
          RgbLed.new(board: board)
        }.to raise_exception('a board and a pin are required for an rgbled')
      end

      it 'should raise if it does not receive a board' do
        expect {
          RgbLed.new(board: board)
        }.to raise_exception('a board and a pin are required for an rgbled')
      end

      it 'should set the pin to out' do
        board.should_receive(:set_pin_mode).with(13, :out)
        RgbLed.new(pin: 13, board: board)
      end

      it 'should set the pin to low' do
        board.should_receive(:digital_write).with(13, Board::LOW)
        RgbLed.new(pin: 13, board: board)
      end
    end

    describe ''
  end
end