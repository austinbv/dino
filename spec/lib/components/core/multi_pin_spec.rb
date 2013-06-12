require 'spec_helper'

module Dino
  module Components
    module Core
      describe MultiPin do
        let(:txrx) { mock(:txrx, add_observer: true, handshake: 14, write: true, read: true) }
        let(:board) { Board.new(txrx) }
        let(:options) { { pins: {red: 9, blue: 10}, board: board } }

        describe '#initialize' do
          it 'should require a pin' do
            expect {
              MultiPin.new(board: board)
            }.to raise_exception
          end

          it 'should require a board' do
            expect {
              MultiPin.new(pins: options[:pins])
            }.to raise_exception
          end
        end

        context "when subclassed" do
          class MPComponent < MultiPin
            def sucessfully_initialized? ; @success ; end

            def options ; @options ; end

            def after_initialize(options={})
              @success = true
              @options = options
              proxy red: BaseOutput, blue: BaseInput
            end
          end

          it "should call #after_initialize with options" do
            component = MPComponent.new(options)
            component.should be_sucessfully_initialized
            component.options.should eq options
          end

          describe '#proxy' do
            it 'should raise if any of the required pins are missing' do
              expect {
                MPComponent.new(board: board, pins: {blue: 11})
              }.to raise_exception(/red/)
            end

            it 'should create the right class of proxy component for each pin with the right options' do
              BaseOutput.should_receive(:new).with({board: board, pin: options[:pins][:red], pullup: nil })
              BaseInput.should_receive(:new).with({board: board, pin: options[:pins][:blue], pullup: true})

              MPComponent.new options.merge(pullups: {blue: true})
            end

            it 'should assign the proxy commponent to the right instance variable' do
              component = MPComponent.new(options)
              component.red.class.should == BaseOutput
              component.blue.class.should == BaseInput
            end

            describe '#states' do
              it 'should return a hash corresponding to the state of each proxy component (pin)' do
                component = MPComponent.new(options)
                component.red.write(128)
                component.blue.update(555)

                component.state.should == {red: 128, blue: 555}
              end
            end
          end
        end
      end
    end
  end
end
