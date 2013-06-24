require 'spec_helper'

module Dino
  module Components
    module Core
      describe BaseInput do
        let(:txrx) { mock(:txrx, add_observer: true, handshake: 14, write: true, read: true) }
        let(:board) { Board.new(txrx) }
        let(:options) { { pin: 'A0', board: board } }
        subject { BaseInput.new(options) }

        describe '#initialize' do
          it 'should add itself as input hardware, set mode to in and start read' do
            board.should_receive(:set_pin_mode).with(14, :in, nil)
            board.should_receive(:add_input_hardware)
            board.should_receive(:start_read)

            BaseInput.new(options)
          end
        end

        context 'callbacks' do
          describe '#add_callback' do
            it 'should add a callback to the :persistent key if no key is given' do
              subject.add_callback { mock }
              subject.instance_variable_get(:@callbacks)[:persistent].should_not be_empty
            end

            it 'should add a callback to the key if a key is given' do
              subject.add_callback(:test) { mock }
              subject.instance_variable_get(:@callbacks)[:test].should_not be_empty
            end
          end

          describe '#remove_callback' do
            it 'should remove all callbacks if no key is given' do
              subject.add_callback { mock }
              subject.remove_callback

              subject.instance_variable_get(:@callbacks).should == {}
            end

            it 'should remove callbacks for the given key if key is given' do
              subject.add_callback { mock }
              subject.add_callback(:test) { mock }
              subject.remove_callback(:test)

              subject.instance_variable_get(:@callbacks)[:test].should be_empty
            end
          end
        end

        context 'reading' do
          describe '#read' do
            it 'should add the block given as a callback to the :read key' do
              subject.should_receive(:add_callback).with(:read)
              subject.read { mock }
            end

            it 'should call #poll once' do
              subject.should_receive(:poll)
              subject.read
            end
          end

          describe '#listen' do
            it 'should add the block given as a callback to the :listen key' do
              subject.should_receive(:add_callback).with(:listen)
              subject.listen { mock }
            end

            it 'should call #start_listening' do
              subject.should_receive(:start_listening)
              subject.listen
            end
          end

          describe '#stop_listening' do
            it 'should tell the board to turn the listener off' do
              board.should_receive(:stop_listener).with(subject.pin)
              subject.stop_listening
            end

            it 'should remove all callbacks with the :listen key' do
              subject.listen { mock }
              subject.should_receive(:remove_callback).with(:listen)

              subject.stop_listening
            end
          end
        end

        describe '#update' do
          it 'should update @state' do
            subject.update("something")
            subject.instance_variable_get(:@state).should == "something"
          end

          it 'should call all callbacks passing in the given data' do
            first_block_data = nil
            second_block_data = nil
            subject.add_callback { |data| first_block_data = data }
            subject.add_callback { |data| second_block_data = data }

            subject.update('Some data')
            [first_block_data, second_block_data].each { |block_data| block_data.should == "Some data" }
          end

          it 'should remove any callbacks keyed with :read' do
            subject.add_callback(:read) { |data| first_block_data = data }

            subject.update("Some data")
            subject.instance_variable_get(:@callbacks)[:read].should be_empty
          end
        end
      end
    end
  end
end
