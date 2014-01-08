require 'spec_helper'

module Dino
  module Components
    module Setup
      describe Input do
        include BoardMock
        let(:options) { { pin: 'A0', board: board, pullup: true} }

        class InputComponent
          include SinglePin
          include Input
        end
        subject { InputComponent.new(options) }

        describe '#pullup=' do
          it 'should tell the board to set the pullup mode correctly' do
            subject
            board.should_receive(:set_pullup).with(subject.pin, false)
            subject.pullup = false
            subject.pullup.should == false
          end
        end

        describe '#initialize_pins' do
          it 'should set the pin mode to in' do
            board.should_receive(:set_pin_mode).with(board.convert_pin(options[:pin]), :in)
            subject
          end

          it 'should set the pulllup if included in options' do
            board.should_receive(:set_pullup).with(subject.pin, true)
            subject
          end

          it 'should tell the board to start reading' do
            board.should_receive(:start_read)
            subject
          end
        end
      end
    end
  end
end
