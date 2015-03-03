require 'spec_helper'

module Dino
  module Components
    module Setup
      describe Input do
        include BoardMock
        let(:options) { { pin: 'A0', board: board, pullup: true} }

        class OutputComponent
          include SinglePin
          include Output
        end
        subject { OutputComponent.new(options) }

        describe '#initialize_pins' do
         it 'should set the pin mode to out' do
            expect(board).to receive(:set_pin_mode).with(board.convert_pin(options[:pin]), :out)
            subject
          end
        end
      end
    end
  end
end
