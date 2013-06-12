require 'spec_helper'

module Dino
  module Components
    module Core
      describe DigitalInput do
        let(:txrx) { mock(:txrx, add_observer: true, handshake: 14, write: true, read: true) }
        let(:board) { Board.new(txrx) }
        let(:options) { { pin: 'A0', board: board } }
        subject { DigitalInput.new(options) }

        describe '#initialize' do
          it 'should start listening immediately' do
            board.should_receive(:digital_listen).with(14)

            component = DigitalInput.new(options)
          end
        end

        describe '#poll' do
          it 'should send #digital_read to the board with its pin' do
            board.should_receive(:digital_read).with(subject.pin)
            subject.read
          end
        end

        describe '#start_listening' do
          it 'should send #digital_listen to the board with its pin' do
            subject
            subject.stop_listening
            board.should_receive(:digital_listen).with(subject.pin)

            subject.start_listening
          end
        end

        context 'callbacks' do
          before :each do
            @low_callback = mock
            @high_callback = mock
            subject.on_low { @low_callback.called }
            subject.on_high { @high_callback.called }
          end

          describe '#on_low' do
            it 'should add a callback that only gets fired when LOW' do
              @low_callback.should_receive(:called)
              @high_callback.should_not_receive(:called)

              subject.update(DigitalInput::LOW)
            end 
          end

          describe '#on_high' do
            it 'should add a callback that only gets fired when HIGH' do
              @low_callback.should_not_receive(:called)
              @high_callback.should_receive(:called)

              subject.update(DigitalInput::HIGH)
            end 
          end
        end
      end
    end
  end
end
