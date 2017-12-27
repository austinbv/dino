require 'spec_helper'

module Dino
  module Components
    module Register
      describe Select do
        include BoardMock
        let(:options) { { pin: '10', board: board } }
        subject { Select.new(options) }

        describe '#initialize' do
          it 'should set mode to output' do
            expect(board).to receive(:set_pin_mode).with(10, :out)
            subject
          end

          it 'should start the board reading' do
            expect(board).to receive(:start_read)
            subject
          end
        end

        describe '#update' do
          it 'should respond to callbacks' do
            subject
            @callback = Proc.new{}
            subject.add_callback(&@callback)
            expect(@callback).to receive(:call).once.with("127")
            subject.update("127")
          end
        end
      end
    end
  end
end
