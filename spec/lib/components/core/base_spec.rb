require 'spec_helper'

module Dino
  module Components
    module Core
      describe Base do
        let(:txrx) { mock(:txrx, add_observer: true, handshake: 14, write: true, read: true) }
        let(:board) { Board.new(txrx) }
        let(:options) { { pin: 'A0', board: board } }
        subject { Base.new(options) }
        
        describe '#initialize' do
          it 'should convert the pin to an integer' do
            board.should_receive(:convert_pin).with(options[:pin])

            component = Base.new(options)
          end

          it 'should require a pin' do
            expect {
              Base.new(board: board)
            }.to raise_exception
          end

          it 'should require a board' do
            expect {
              Base.new(pin: 'A0')
            }.to raise_exception
          end
        end

        context "when subclassed" do
          class SpecComponent < Base
            def sucessfully_initialized? ; @success ; end

            def options ; @options ; end

            def after_initialize(options={})
              @success = true
              @options = options
            end
          end

          it "should call #after_initialize with options" do
            component = SpecComponent.new(options)
            component.should be_sucessfully_initialized
            component.options.should eq options
          end
        end

        describe '#mode=' do
          it 'should tell the board to set the pin mode' do
            board.should_receive(:set_pin_mode).with(subject.pin, :out, nil)

            subject.send(:mode=, :out)
            subject.mode.should == :out 
          end
        end

        describe '#pullup=' do
          it 'should tell the board to set the pullup mode' do
            board.should_receive(:set_pullup).with(subject.pin, true)

            subject.send(:pullup=, true)
            subject.pullup.should == true
          end
        end
      end
    end
  end
end
