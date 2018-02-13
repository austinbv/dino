require 'spec_helper'

module Dino
  module Components
    module Mixins
      describe Poller do

        class PollComponent
          include Setup::Base
          include Poller
          def _read; end
          def initialize; after_initialize; end
        end

        subject { PollComponent.new }

        describe '#initialize' do
          it 'should automatically include Callbacks' do
            expect(subject.class.ancestors).to include(Threaded)
            expect(subject.class.ancestors).to include(Reader)
          end
        end

        describe '#poll' do
          it 'should call #stop' do
            expect(subject).to receive(:stop)
            subject.poll
          end

          it 'should add a given block as callback with :poll key' do
            callback = Proc.new{}
            expect(subject).to receive(:add_callback).with(:poll) do |&block|
              expect(block).to eq(callback)
            end
            subject.poll(&callback)
          end

          it 'should start a new thread' do
            expect(subject).to receive(:threaded_loop)
            subject.poll
            subject.stop
          end

          it 'should call #_read repeatedly' do
            expect(subject).to receive(:_read).at_least(:twice)
            subject.poll(0.01)
            sleep 0.1
            subject.stop
          end
        end

        describe '#stop' do
          it 'should not override the call to Threaded#stop_thread' do
            expect(subject).to receive(:stop_thread)
            subject.stop
          end

          it 'should remove any callbacks with the :poll key' do
            expect(subject).to receive(:remove_callbacks).with(:poll)
            subject.stop
          end
        end
      end
    end
  end
end
