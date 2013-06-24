require 'spec_helper'

module Dino
  module Components
    module Core
      describe BaseOutput do
        let(:txrx) { mock(:txrx, add_observer: true, handshake: 14, write: true, read: true) }
        let(:board) { Board.new(txrx) }
        let(:options) { { pin: 'A0', board: board } }
        subject { BaseOutput.new(options) }

        before(:each) { subject }

        describe '#initialize' do
          it 'should set mode to out and go low' do
            board.should_receive(:set_pin_mode).with(14, :out, nil)
            board.should_receive(:digital_write).with(14, board.low)

            BaseOutput.new(options)
          end
        end

        describe '#digital_write' do
          it 'should update the @state instance variable and call #digital_write on the board' do
            board.should_receive(:digital_write).with(subject.pin, board.high).once
            
            subject.digital_write(board.high)
            subject.state.should == board.high
          end
        end

        describe '#analog_write' do
          it 'should update the @state instance variable and call #analog_write on the board' do
            board.should_receive(:analog_write).with(subject.pin, 128).once
            
            subject.analog_write(128)
            subject.state.should == 128
          end
        end

        describe '#write' do
          it 'should call #digital_write if value is HIGH' do
            subject.should_receive(:digital_write).with(board.high)
            subject.write(board.high)
          end


          it 'should call #digital_write if value is LOW' do
            subject.should_receive(:digital_write).with(board.low)
            subject.write(board.low)
          end

          it 'should call #analog_write if value is anything else' do
            subject.should_receive(:analog_write).with(128)
            subject.write(128)
          end
        end

        describe '#high' do
          it 'should call #digital_write with HIGH' do
            subject.should_receive(:digital_write).with(board.high)
            subject.high
          end
        end

        describe '#low' do
          it 'should call #digital_write with LOW' do
            subject.should_receive(:digital_write).with(board.low)
            subject.low
          end
        end

        describe '#toggle' do
          it 'should call high if currently LOW' do
            subject.low
            subject.should_receive(:high)

            subject.toggle
          end

          it 'should call LOW if anything else' do
            subject.high
            subject.should_receive(:low)

            subject.toggle
          end
        end
      end
    end
  end
end
