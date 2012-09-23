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
      end
    end
  end
end
