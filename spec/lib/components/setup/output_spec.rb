require 'spec_helper'

module Dino
  module Components
    module Setup
      describe Input do
        let(:txrx) { mock(:txrx, add_observer: true, handshake: 14, write: true, read: true) }
        let(:board) { Board.new(txrx) }
        let(:options) { { pin: 'A0', board: board, pullup: true} }
        class OutputComponent
          include SinglePin
          include Output
        end
        subject { OutputComponent.new(options) }

        describe '#initialize_pins' do
         it 'should set the pin mode to in' do
            board.should_receive(:set_pin_mode).with(board.convert_pin(options[:pin]), :out)
            subject
          end
        end
      end
    end
  end
end
