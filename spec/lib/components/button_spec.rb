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

        it 'should add itself to the board and start reading' do
          board = mock(:board)
          board.should_receive(:add_digital_hardware)
          board.should_receive(:start_read)
          Button.new(board: board, pin: 'a pin')
        end
      end

      context 'callbacks' do
        let(:board) { mock(:board, add_digital_hardware: true, start_read: true) }
        let(:button) {Button.new(board: board, pin: mock)}
        describe '#down' do
          it 'should add a callback to the down_callbacks array' do
            callback = mock
            button.down do 
              callback.called
            end
            down_callbacks = button.instance_variable_get(:@down_callbacks)
            down_callbacks.size.should == 1
            callback.should_receive(:called)
            down_callbacks.first.call
          end
        end

        describe '#up' do
          it 'should add a callback to the up_callbacks array' do
            callback = mock
            button.up do 
              callback.called
            end
            up_callbacks = button.instance_variable_get(:@up_callbacks)
            up_callbacks.size.should == 1
            callback.should_receive(:called)
            up_callbacks.first.call
          end
        end

        describe '#update' do
          it 'should call the down callbacks' do
            callback_1 = mock
            button.down do 
              callback_1.called
            end
            
            callback_2 = mock
            button.down do 
              callback_2.called
            end
            callback_1.should_receive(:called)
            callback_2.should_receive(:called)
            button.update(Button::DOWN)
          end

          it 'should call the up callbacks' do
            callback_1 = mock
            button.up do 
              callback_1.called
            end
            
            callback_2 = mock
            button.up do 
              callback_2.called
            end

            button.instance_variable_set(:@state, Button::DOWN)

            callback_1.should_receive(:called)
            callback_2.should_receive(:called)
            button.update(Button::UP)
          end

          it 'should not call the callbacks if the state has not changed' do
            callback = mock
            button.up do
              callback.called
            end

            callback.should_not_receive(:called)
            button.update(Button::UP)
            button.update(Button::UP)
          end

          it 'should not call the callbacks if the data is not UP or DOWN' do
            callback_1 = mock
            button.up do 
              callback_1.called
            end

            callback_2 = mock
            button.down do 
              callback_2.called
            end

            callback_1.should_not_receive(:called)
            callback_2.should_not_receive(:called)
            button.update('foobarred')
          end
        end
      end
    end
  end
end
