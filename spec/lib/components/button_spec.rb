require 'spec_helper'

module Dino
  module Components
    describe Button do
      describe '#initialize' do
        it 'should raise if it does not receive a pin' do
          expect {
            Button.new(board: 'a board')
          }.to raise_exception
        end

        it 'should raise if it does not receive a board' do
          expect {
            Button.new(pin: 'a pin')
          }.to raise_exception
        end

        it 'should add itself to the board, start read and digital listen' do
          board = mock(:board)
          board.should_receive(:add_input_hardware)
          board.should_receive(:start_read)
          board.should_receive(:digital_listen).with(7)

          Button.new(board: board, pin: 7)
        end
      end

      context 'callbacks' do
        let(:board) { mock(:board, add_input_hardware: true, start_read: true, digital_listen: true) }
        let(:button) {Button.new(board: board, pin: mock)}
        describe '#down' do
          it 'should add a callback to @callbacks[:low]' do
            callback = mock
            button.down do 
              callback.called
            end
            down_callbacks = button.instance_variable_get(:@callbacks)[:low]
            down_callbacks.size.should == 1
          end
        end

        describe '#up' do
          it 'should add a callback to @callbacks[:high]' do
            callback = mock
            button.up do 
              callback.called
            end
            up_callbacks = button.instance_variable_get(:@callbacks)[:high]
            up_callbacks.size.should == 1
          end
        end

        describe '#update' do
          it 'should call @callbacks[:high] only when HIGH' do
            high_callback = mock
            low_callback = mock
            button.up   { high_callback.called }
            button.down { low_callback.calles }
            
            high_callback.should_receive(:called)
            low_callback.should_not_receive(:called)
            button.update(1)
          end

          it 'should call @callbacks[:low] only when LOW' do
            high_callback = mock
            low_callback = mock
            button.up   { high_callback.called }
            button.down { low_callback.called }
            
            high_callback.should_not_receive(:called)
            low_callback.should_receive(:called)
            button.update(0)
          end
        end
      end
    end
  end
end
