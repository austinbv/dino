require 'spec_helper'

module Dino
  module Components
    describe Servo do
      include BoardMock
      let(:options) { { board: board, pin: 9 } }
      subject { Servo.new(options)  }

      describe '#initialize' do
        it 'should toggle the servo library on for the pin' do
          expect(board).to receive(:servo_toggle).with(options[:pin], :on)
          subject
        end
      end

      describe '#position' do
        let(:servo) {servo =  Servo.new(pin: 13, board: board)}

        it 'should set the position of the Servo' do
          servo.position = 90
          expect(servo.position).to eq(90)
        end

        it 'should let you write up to 180' do
          servo.position = 180
          expect(servo.position).to eq(180)
        end

        it 'should modulate when position > 180' do
          servo.position = 190
          expect(servo.position).to eq(10)
        end

        it 'should write the new position to the board' do
          expect(board).to receive(:servo_write).with(13, 10)
          servo.position = 190
        end
      end
    end
  end
end
