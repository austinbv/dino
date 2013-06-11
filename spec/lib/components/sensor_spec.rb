require 'spec_helper'

module Dino
  module Components
    describe Sensor do

      let(:board){mock(:board).as_null_object}
      let(:sensor) {Sensor.new(board: board, pin: 7)}

      describe '#initalize' do
        it 'should raise if it does not receive a pin' do
          expect { Sensor.new(board: board) }.to raise_exception
        end

        it 'should raise if it does not receive a board' do
          expect { Sensor.new(pin: 7) }.to raise_exception
        end

        it 'should add itself to the board and start read' do
          board.should_receive(:add_input_hardware)
          board.should_receive(:start_read)
          Sensor.new(board: board, pin: 7)
        end

        it 'should initalize callbacks' do
          sensor.instance_variable_get(:@callbacks).should == {}
        end
      end

      describe '#read' do
        it 'should tell the board to read once' do
          board.should_receive(:analog_read).with(7)
          sensor.read
        end

        it 'should accept a callback as block and add to @callbacks[:read]'
      end

      describe '#listen' do
        it 'should tell the board to start listening' do
          board.should_receive(:analog_listen).with(7)
          sensor.listen
        end

        it 'should accept a callback as block and add to @callbacks[:listen]'
      end

      describe '#add_callback' do
        it 'should require a key'
        it 'should add the block to the array corresponding to the key in the @callbacks hash'
      end

      describe '#clear_callbacks' do
        it 'should clear all callbacks if called with no key' do
          sensor.on_data { |data| puts data }
          sensor.on_data(:test) { |data| puts data }
          sensor.clear_callbacks
          sensor.instance_variable_get(:@callbacks).should == {}
        end

        it 'should clear callbacks of a particular key if called with a key'
      end

      describe '#on_data' do 
        it "should add a callback with the :persistent key" do
          sensor.on_data { "this is a block" }
          sensor.instance_variable_get(:@callbacks)[:persistent].should_not be_empty
        end
      end

      describe '#update' do
        it 'should call all callbacks passing in the given data' do
          sensor = Sensor.new(board: board, pin: 'a pin')
          
          first_block_data = nil
          second_block_data = nil
          sensor.on_data do |data|
            first_block_data = data
          end
          sensor.on_data do |data|
            second_block_data = data
          end

          sensor.update('Some data')
          [first_block_data, second_block_data].each { |block_data| block_data.should == "Some data" }
        end
      end
    end
  end
end
