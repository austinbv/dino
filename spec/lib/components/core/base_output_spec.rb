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
            board.should_receive(:digital_write).with(14, Board::LOW)

            BaseOutput.new(options)
          end
        end

        describe '#digital_write' do
          it 'should update the @state instance variable and call #digital_write on the board' do
            board.should_receive(:digital_write).with(subject.pin, Board::HIGH).once
            
            subject.digital_write(Board::HIGH)
            subject.state.should == Board::HIGH
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
            subject.should_receive(:digital_write).with(Board::HIGH)
            subject.write(Board::HIGH)
          end


          it 'should call #digital_write if value is LOW' do
            subject.should_receive(:digital_write).with(Board::LOW)
            subject.write(Board::LOW)
          end

          it 'should call #analog_write if value is anything else' do
            subject.should_receive(:analog_write).with(128)
            subject.write(128)
          end
        end

        describe '#high' do
          it 'should call #digital_write with HIGH' do
            subject.should_receive(:digital_write).with(Board::HIGH)
            subject.high
          end
        end

        describe '#low' do
          it 'should call #digital_write with LOW' do
            subject.should_receive(:digital_write).with(Board::LOW)
            subject.low
          end
        end
      end
    end
  end
end
