require 'spec_helper'

module Dino
  module Components
    module Mixins
      describe Poller do

        class ListenComponent
          include Setup::Base
          include Listener
          def _listen(divider=nil); end
          def _stop_listener; end
          def initialize; after_initialize; end
        end

        subject { ListenComponent.new }

        describe '#initialize' do
          it 'should automatically include Callbacks' do
            expect(subject.class.ancestors).to include(Callbacks)
          end
        end

        describe '#listen' do
          it 'should call #stop' do
            expect(subject).to receive(:stop)
            subject.listen
          end

          it 'should call #_listen' do
            expect(subject).to receive(:_listen)
            subject.listen
          end

          it 'should add a given block as callback with :listen key' do
            callback = Proc.new{}
            expect(subject).to receive(:add_callback).with(:listen) do |&block|
              expect(block).to eq(callback)
            end
            subject.listen(&callback)
          end
        end

        describe '#stop' do
          it 'should call #_stop_listener' do
            expect(subject).to receive(:_stop_listener)
            subject.listen
          end

          it 'should remove all callbacks with the :listen key' do
            expect(subject).to receive(:remove_callbacks).with(:listen)
            subject.stop
          end
        end
      end
    end
  end
end
