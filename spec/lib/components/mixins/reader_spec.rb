require 'spec_helper'

module Dino
  module Components
    module Mixins
      describe Reader do

        class ReadComponent
          include Setup::Base
          include Reader
          def _read; end
          def initialize; after_initialize; end
        end

        subject { ReadComponent.new }

        def read_callbacks
          subject.instance_variable_get(:@callbacks)[:read]
        end

        def inject(data, wait_for_callbacks = true)
          Thread.new do
            if wait_for_callbacks
              while (!read_callbacks) do; sleep 0.01; end
            end
            loop do
              sleep 0.01
              subject.update(data)
              break unless read_callbacks
            end
          end
        end

        describe '#initialize' do
          it 'should automatically include Callbacks' do
            expect(ReadComponent.ancestors).to include(Callbacks)
          end
        end

        describe '#read' do
          it 'should call #_read exactly once' do
            expect(subject).to receive(:_read).exactly(1).times
            inject(1)
            subject.read
          end

          it 'should add the given block as a callback with key :read' do
            callback = Proc.new{}

            # expect(subject).to receive(:add_callback).with(:read, &callback)
            # would just be too easy?
            blocks = []
            allow(subject).to receive(:add_callback).with(:read) do |&block|
              blocks << block
              expect(blocks).to include(callback)
            end

            inject(1)
            subject.read(&callback)
          end

          it 'should run the given callback exactly once' do
            callback = Proc.new{}
            expect(callback).to receive(:call).exactly(1).times
            inject(1)
            subject.read(&callback)
            inject(1, false)
          end

          it 'should return the read value' do
            inject("Hello")
            expect(subject.read).to eq("Hello")
          end
        end
      end
    end
  end
end
