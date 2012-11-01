require 'spec_helper'

module Dino
  module Components
    describe Sensor do

      let(:board){mock(:board).as_null_object}

      describe '#initalize' do
        it 'should raise if it does not receive a pin' do
          expect {
            Sensor.new(board: 'a board')
          }.to raise_exception
        end

        it 'should raise if it does not receive a board' do
          expect {
            Sensor.new(pin: 'a pin')
          }.to raise_exception
        end

        it 'should add itself to the board and start reading' do
          board.should_receive(:add_analog_hardware)
          board.should_receive(:start_read)
          Sensor.new(board: board, pin: 'a pin')
        end

        it 'should initalize data_callbacks' do
          sensor = Sensor.new(board: board, pin: 'a pin')
          sensor.instance_variable_get(:@data_callbacks).should == []
        end
      end

      describe '#when_data_received' do
        it 'should add a callback back to the list of callbacks' do
          sensor = Sensor.new(board: board, pin: 'a pin')
          sensor.when_data_received 'Foo'
          sensor.instance_variable_get(:@data_callbacks).should == ['Foo']
        end
      end

      describe '#update' do
        it 'should call all callbacks passing in the given data' do
          first_callback, second_callback = mock, mock
          first_callback.should_receive(:call).with('Some data')
          second_callback.should_receive(:call).with('Some data')

          sensor = Sensor.new(board: board, pin: 'a pin')

          sensor.when_data_received first_callback
          sensor.when_data_received second_callback

          sensor.update('Some data')
        end
      end
    end
  end
end
