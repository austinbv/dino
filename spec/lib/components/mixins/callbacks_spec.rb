require 'spec_helper'

module Dino
  module Components
    module Mixins
      describe Callbacks do

        class CallbackComponent
          include Callbacks
          def initialize; after_initialize; end
        end
        subject { CallbackComponent.new }

        describe '#initialize' do
          it 'should have an empty hash to hold callbacks' do
            expect(subject.instance_variable_get :@callbacks).to eq({})
          end

          it 'should have a mutex to protect access to the hash' do
            expect(subject.instance_variable_get(:@callback_mutex).class).to equal(Mutex)
          end
        end

        describe '#add_callback' do
          it 'should atomically add a callback to the hash' do
            expect(subject.instance_variable_get :@callback_mutex).to receive(:synchronize).once.and_yield
            callback = Proc.new{}
            subject.add_callback(&callback)
            expect(subject.instance_variable_get :@callbacks).to eq({persistent: [callback]})
          end

          it 'should add callbacks under arbitrary keys' do
            callback = Proc.new{}
            subject.add_callback(:key, &callback)
            expect(subject.instance_variable_get :@callbacks).to eq({key: [callback]})
          end
        end

        context 'with callbacks added' do
          before :each do
            @callback1 = Proc.new{}
            @callback2 = Proc.new{}
            subject.add_callback(&@callback1)
            subject.add_callback(:read, &@callback2)
          end

          describe '#remove_callback' do
            it 'should remove all callbacks if no key given' do
              subject.remove_callbacks
              expect(subject.instance_variable_get :@callbacks).to eq({})
            end

            it 'should remove only callbacks for a specific key given' do
              subject.remove_callbacks(:read)
              expect(subject.instance_variable_get(:@callbacks)[:read]).to eq([])
              expect(subject.instance_variable_get(:@callbacks)[:persistent]).to_not eq([])
            end
          end

          describe '#update' do
            it 'should set the @state variable' do
              subject.update("thing")
              expect(subject.instance_variable_get :@state).to eq("thing")
            end

            it 'should call all the callbacks' do
              expect(@callback1).to receive(:call).once
              expect(@callback2).to receive(:call).once
              subject.update("data")
            end

            it 'should remove any callbacks saved with the key :read' do
              subject.update("data")
              expect(subject.instance_variable_get(:@callbacks)[:read]).to eq([])
            end
          end
        end
      end
    end
  end
end
