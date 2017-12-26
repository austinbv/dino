require 'spec_helper'

module Dino
  module Components
    describe IREmitter do
      include BoardMock
      let(:options) { { board: board, pin: 3 } }
      subject { IREmitter.new(options)  }

      describe '#send' do
        before(:each) { subject }

        it 'should send messages in the request format the board expects' do
          expect(board).to receive(:write).with "16.3.38.#{[4].pack('C')}#{[100,200,300,400].pack('v*')}\n"

          subject.send([100,200,300,400])
        end

        it 'should put modulation frequency (kHz) in the value field if given as option to #send' do
          expect(board).to receive(:write).with "16.3.40.#{[4].pack('C')}#{[100,200,300,400].pack('v*')}\n"

          subject.send([100,200,300,400], frequency: 40)
        end
      end
    end
  end
end
