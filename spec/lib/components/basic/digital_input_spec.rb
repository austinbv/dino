require 'spec_helper'

module Dino
  module Components
    module Basic
      describe DigitalInput do
        include BoardMock
        let(:options) { { pin: 'A0', board: board } }
        subject { DigitalInput.new(options) }

        it 'should start listening immediately' do
          expect(board).to receive(:digital_listen).with(14)
          component = DigitalInput.new(options)
        end

        describe '#_read' do
          it 'should call board#digital_read with its pin once' do
            expect(board).to receive(:digital_read).with(subject.pin).once
            subject._read
          end
        end

        describe '#_listen' do
          it 'should call board#digital_listen with its pin once' do
            expect(board).to receive(:digital_listen).with(subject.pin).once
            subject._listen
          end
        end

        context 'callbacks' do
          before :each do
            @low_callback = double
            @high_callback = double
            subject.on_low { @low_callback.called }
            subject.on_high { @high_callback.called }
          end

          describe '#on_low' do
            it 'should add a callback that only gets fired when LOW' do
              expect(@low_callback).to receive(:called)
              expect(@high_callback).not_to receive(:called)

              subject.update(board.low)
            end
          end

          describe '#on_high' do
            it 'should add a callback that only gets fired when HIGH' do
              expect(@high_callback).to receive(:called)
              expect(@low_callback).not_to receive(:called)

              subject.update(board.high)
            end
          end
        end
      end
    end
  end
end
