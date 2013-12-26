require 'spec_helper'

module Dino
  module Components
    module Setup
      describe Base do
        let(:txrx) { mock(:txrx, add_observer: true, handshake: 14, write: true, read: true) }
        let(:board) { Board.new(txrx) }
        let(:options) { { pin: 'A0', board: board } }
        class BaseComponent; include Base; end
        subject { BaseComponent.new(options) }
        
        describe '#initialize' do
          it 'should require a board' do
            expect {
              BaseComponent.new(pin: 'A0')
            }.to raise_exception
          end

          it 'should add itself to the board' do
            board.should_receive(:add_component)
            BaseComponent.new(options)
          end
        end
      end
    end
  end
end
