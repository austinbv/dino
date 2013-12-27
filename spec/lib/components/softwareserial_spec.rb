require 'spec_helper'

module Dino
  module Components
    describe SoftwareSerial do
      include BoardMock

      subject { SoftwareSerial.new board: board, pins: { rx: 10, tx: 11 }, baud: 4800 }

      before do
        board.should_receive(:write).with("12..0.10,11\n")
        board.should_receive(:write).with("12..1.4800\n")
      end

      describe '#puts' do
        it 'prints a string to the serial interface' do
          board.should_receive(:write).with "12..3.Testing\n"
          subject.puts("Testing")
        end
      end
    end
  end
end