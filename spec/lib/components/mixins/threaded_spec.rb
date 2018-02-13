require 'spec_helper'

module Dino
  module Components
    module Mixins
      describe Threaded do
        include BoardMock

        class ThreadedComponent
          include Setup::Base
          include Threaded
          def foo(str="test")
            @bar = str
          end
          attr_reader :bar
          interrupt_with :foo
        end

        subject { ThreadedComponent.new(board: board) }

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
            component = subject
            component.threaded {}
            while(!component.instance_variable_get :@thread) do; end
            expect(component.instance_variable_get :@thread).to_not eq(thread)
          end
        end

        describe '#threaded_loop' do
          it 'should loop the block in the thread' do
            component = subject
            main_thread = Thread.current
            async_thread = Thread.current
            async = Proc.new { async_thread = Thread.current}

            expect(async).to receive(:call).and_call_original
            allow_any_instance_of(ThreadedComponent).to receive(:loop) do |&block|
              expect(block).to eq(async)
            end.and_yield

            component.threaded_loop(&async)
            while(main_thread == async_thread) do; end
            component.stop_thread
            expect(main_thread).to_not eq(async_thread)
          end
        end

        describe '#stop_thread' do
          it 'should kill the thread' do
            component = subject
            component.threaded { sleep }
            expect(component.instance_variable_get :@thread).to receive(:kill)
            component.stop_thread
          end
        end

        describe '#enable_interrupts' do
          it 'should override the given method on the singleton class only' do
            first_part = subject
            second_part = ThreadedComponent.new(board: board)
            before_class = second_part.method(:foo)
            before_instance = first_part.method(:foo)

            first_part.enable_interrupts
            after_class = second_part.method(:foo)
            after_instance = first_part.method(:foo)

            expect(after_class).to eq(before_class)
            expect(after_instance).to_not eq(before_instance)
          end

          it 'should pass arguments through to the original method' do
            component = subject
            original = component.method(:foo)
            component.enable_interrupts
            component.foo("dino")
            expect(original).to_not eq(component.method(:foo))
            expect(component.bar).to eq("dino")
          end
        end

        describe 'calling an interrupt' do
          it 'should stop the thread' do
            component = subject
            component.threaded { sleep }
            expect(component).to receive(:stop_thread)
            component.foo
          end
        end
      end
    end
  end
end
