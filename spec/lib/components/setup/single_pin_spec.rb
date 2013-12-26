require 'spec_helper'

module Dino
  module Components
    module Setup
      describe SinglePin do
        let(:txrx) { mock(:txrx, add_observer: true, handshake: 14, write: true, read: true) }
        let(:board) { Board.new(txrx) }
        let(:options) { { pin: 'A0', board: board } }
        class SinglePinComponent; include SinglePin; end
        subject { SinglePinComponent.new(options) }
        
        describe '#initialize' do
          it 'should require a pin' do
            expect {
              SinglePinComponent.new(board: board)
            }.to raise_exception
          end

          it 'should convert the pin to an integer' do
            board.should_receive(:convert_pin).with(options[:pin])
            component = SinglePinComponent.new(options)
          end
        end

        describe '#mode=' do
          it 'should tell the board to set the pin mode' do
            board.should_receive(:set_pin_mode).with(subject.pin, :out)

            subject.send(:mode=, :out)
            subject.mode.should == :out
          end
        end
      end
    end
  end
end
