require 'spec_helper'

module Dino
  module Components
    module Setup
      describe SinglePin do
        include BoardMock
        let(:options) { { pin: 'A0', board: board } }

        class SinglePinComponent
          include SinglePin
        end
        subject { SinglePinComponent.new(options) }

        describe '#initialize' do
          it 'should require a pin' do
            expect {
              SinglePinComponent.new(board: board)
            }.to raise_exception
          end

          it 'should convert the pin to an integer' do
            expect(board).to receive(:convert_pin).with(options[:pin])
            component = SinglePinComponent.new(options)
          end
        end

        describe '#mode=' do
          it 'should tell the board to set the pin mode' do
            expect(board).to receive(:set_pin_mode).with(subject.pin, :out)

            subject.send(:mode=, :out)
            expect(subject.mode).to eq(:out)
          end
        end
      end
    end
  end
end
