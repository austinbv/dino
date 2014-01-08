require 'spec_helper'

module Dino
  module Components
    module Basic
      describe AnalogInput do
        include BoardMock
        let(:options) { { pin: 'A0', board: board } }
        subject { AnalogInput.new(options) }

        describe '#_read' do
          it 'should send #analog_read to the board with its pin' do
            board.should_receive(:analog_read).with(subject.pin)
            subject._read
          end
        end

        describe '#_listen' do
          it 'should send #analog_listen to the board with its pin' do
            board.should_receive(:analog_listen).with(subject.pin)
            subject._listen
          end
        end
      end
    end
  end
end
