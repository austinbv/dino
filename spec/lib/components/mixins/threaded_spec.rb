require 'spec_helper'

module Dino
  module Components
    module Mixins
      describe Threaded do

        class ThreadedComponent
          include Threaded
          def foo(str="test")
            @bar = str
          end
          attr_reader :bar
          interrupt_with :foo
        end

        subject { ThreadedComponent.new }

        describe 'ClassMethods' do
          it 'should add methods to interrupt the thread using #interrupt_with' do
            ThreadedComponent.class_variable_get(:@@interrupts).should eq [:foo]
          end
        end

        describe '#threaded' do
          it 'should stop any existing thread' do
            expect(subject).to receive(:stop_thread)
            subject.threaded do; end
          end

          it 'should enable interrupts' do
            expect(subject).to receive(:enable_interrupts)
            subject.threaded do; end
          end

          it 'should start a new thread that calls the given block' do
            async = Proc.new {}
            expect(Thread).to receive(:new) do |&block|
              expect(block).to eq(async)
            end
            subject.threaded(&async)
          end

          it 'should store in @thread' do
            thread = Thread.current
            async = Proc.new { thread = Thread.current }
            subject.threaded(&async)
            sleep 0.25
            expect(subject.instance_variable_get :@thread).to eq thread
          end
        end

        describe '#threaded_loop' do
          it 'should loop the block in the thread' do
            async = Proc.new {}
            expect(subject).to receive(:loop) do |&block|
              expect(block).to eq(async)
            end

            subject.threaded_loop(&async)
            sleep 0.25
            subject.stop_thread
          end
        end

        describe '#stop_thread' do
          it 'should kill the thread' do
            subject.threaded { sleep }
            expect(subject.instance_variable_get :@thread).to receive(:kill)
            subject.stop_thread
          end
        end

        describe '#enable_interrupts' do
          it 'should override the given method on the singleton class only' do
            second_part = ThreadedComponent.new
            before_class = second_part.method(:foo)
            before_instance = subject.method(:foo)

            subject.enable_interrupts
            after_class = second_part.method(:foo)
            after_instance = subject.method(:foo)

            expect(after_class).to eq(before_class)
            expect(after_instance).to_not eq(before_instance)
          end

          it 'should pass arguments through to the original method' do
            subject.enable_interrupts
            subject.foo("dino")
            expect(subject.bar).to eq("dino")
          end
        end

        describe 'calling an interrupt' do
          it 'should stop the thread' do
            subject.threaded { sleep }
            expect(subject).to receive(:stop_thread)
            subject.foo
          end
        end
      end
    end
  end
end
