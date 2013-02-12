require 'spec_helper'

module Dino
  module Components
    describe Servo do
      let(:board) { mock(:board, analog_write: true, set_pin_mode: true) }

      describe '#initialize' do
        it 'should raise if it does not receive a pin' do
          expect {
            Servo.new(board: board)
          }.to raise_exception
        end

        it 'should raise if it does not receive a board' do
          expect {
            Servo.new(pin: 13)
          }.to raise_exception
        end

        it 'should set the pins to out' do
          board.should_receive(:set_pin_mode).with(13, :out, nil)
          Servo.new(pin: 13, board: board)
        end

        it 'should set the inital position to 0' do
          servo =  Servo.new(pin: 13, board: board)
          servo.instance_variable_get(:@position).should == 0
        end
      end

      describe '#position' do
        let(:servo) {servo =  Servo.new(pin: 13, board: board)}

        it 'should set the position of the Servo' do
          servo.position = 90
          servo.instance_variable_get(:@position).should == 90
        end

        it 'should modulate the position at 180' do
          servo.position = 190
          servo.instance_variable_get(:@position).should == 10
        end

        it 'should write the new position to the board' do
          servo.should_receive(:analog_write).with(10)
          servo.position = 190
        end
      end
    end
  end
end

