require 'spec_helper'

module Dino
  module Components
    module Core
      describe Threaded do
        class ThreadedComponent
          include Threaded
          interrupt_with :interrupt_it
          def interrupt_it; end
          def dont_interrupt_it; end
        end

        subject { ThreadedComponent.new }

        describe '#threaded' do
          it 'should stop the existing thread' do
            subject.should_receive(:stop_thread)
            subject.threaded { mock }
          end

          it 'should enable interrupts on the first threaded call' do
            subject.should_receive(:enable_interrupts).once
            thread = subject.threaded { mock }
          end

          it 'should start a thread and call the block passed.' do
            block = mock
            Thread.should_receive(:new).once.and_yield
            block.should_receive(:call)

            subject.threaded { block.call }
          end
        end

        describe '#stop_thread' do
          it 'should kill the internal thread' do
            subject.threaded { sleep }
            subject.thread.should_receive(:kill)

            subject.stop_thread
          end
        end

        describe '#enable_interrupts' do
          it 'should set @enable_interrupts to true' do
            subject.enable_interrupts
            subject.interrupts_enabled.should == true
          end
        end

        context 'interrupts' do
          it 'should make method names passed to #interrupt_with stop the internal thread' do
            subject.threaded { sleep }
            subject.should_receive(:stop_thread)

            subject.interrupt_it
          end

          it 'should not make other methods stop the internal thread' do
            subject.threaded { sleep }
            subject.should_not_receive(:stop_thread)

            subject.dont_interrupt_it
          end
        end

        context 'with multiple threads' do
          it 'should let other threads interrupt the internal thread' do
            subject.threaded {sleep}
            subject.should_receive(:stop_thread)

            subject.interrupt_it
          end

          it 'should not let the internal thread interrupt itself' do
            subject.should_receive(:interrupt_it).exactly(10).times
            subject.should_not_receive(:stop_thread)

            # Simulate being inside the internal thread.
            subject.enable_interrupts
            subject.instance_variable_set(:@thread, Thread.current)
            10.times { subject.interrupt_it }
          end
        end

        context 'when included and then subclassed' do
          it 'should allow calling #interrupt_with again' do
            class SubThreaded < ThreadedComponent
              interrupt_with :stop_it
              def stop_it; end
            end

            component = SubThreaded.new
            component.threaded { sleep }
            component.should_receive(:stop_thread)

            component.stop_it
          end
        end
      end
    end
  end
end
