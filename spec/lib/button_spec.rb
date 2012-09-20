require 'spec_helper'

module Dino
  describe Button do
    let(:board) { mock(:board, digital_write: true, set_pin_mode: true, add_observer: true, start_read: true) }

    describe '#initialize' do
      it 'should raise if it does not receive a pin' do
        expect {
          Button.new(board: board)
        }.to raise_exception('a board and a pin are required for an button')
      end

      it 'should raise if it does not receive a board' do
        expect {
          Button.new(board: board)
        }.to raise_exception('a board and a pin are required for an button')
      end
    end
  end
end