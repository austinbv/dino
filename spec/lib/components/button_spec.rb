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
            button.down(callback_mock = mock)
            button.instance_variable_get(:@down_callbacks).should include callback_mock
          end
        end

        describe '#up' do
          it 'should add a callback to the up_callbacks array' do
            button.up(callback_mock = mock)
            button.instance_variable_get(:@up_callbacks).should include callback_mock
          end
        end

        describe '#update' do
          it 'should call the down callbacks' do
            button.down(callback_mock1 = mock)
            button.down(callback_mock2 = mock)
            callback_mock1.should_receive(:call)
            callback_mock2.should_receive(:call)
            button.update(Button::DOWN)
          end

          it 'should call the up callbacks' do
            button.up(callback_mock1 = mock)
            button.up(callback_mock2 = mock)

            button.instance_variable_set(:@state, Button::DOWN)

            callback_mock1.should_receive(:call)
            callback_mock2.should_receive(:call)
            button.update(Button::UP)
          end

          it 'should not call the callbacks if the state has not changed' do
            button.up(callback_mock = mock)

            callback_mock.should_not_receive(:call)
            button.update(Button::UP)
            button.update(Button::UP)
          end

          it 'should not call the callbacks if the data is not UP or DOWN' do
            button.up(callback_mock1 = mock)
            button.down(callback_mock2 = mock)

            callback_mock1.should_not_receive(:call)
            callback_mock2.should_not_receive(:call)
            button.update('foobarred')
          end
        end
      end
    end
  end
end
