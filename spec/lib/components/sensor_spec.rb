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
        
        it "should add a callback to the list of callbacks" do
          sensor = Sensor.new(board: board, pin: 'a pin')
          sensor.when_data_received { "this is a block" }
          sensor.instance_variable_get(:@data_callbacks).should_not be_empty
        end
      end

      describe '#update' do
        it 'should call all callbacks passing in the given data' do
          sensor = Sensor.new(board: board, pin: 'a pin')
          
          first_block_data = nil
          second_block_data = nil
          sensor.when_data_received do |data|
            first_block_data = data
          end
          sensor.when_data_received do |data|
            second_block_data = data
          end

          sensor.update('Some data')
          [first_block_data, second_block_data].each { |block_data| block_data.should == "Some data" }
        end
      end
    end
  end
end
