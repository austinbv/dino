require 'spec_helper'

module Dino
  module Components
    module OneWire
      describe Slave do
        include BoardMock
        let(:bus) { double(mutex: Mutex.new).as_null_object }
        subject   { Slave.new(bus: bus, address: 0xFFFFFFFFFFFFFFFF) }

        describe '#after_initialize' do
          it 'should require an address' do
            expect { Slave.new(bus: bus) }.to raise_error
          end
        end

        describe '#atomically' do
          it 'should happen inside the mutex lock' do
            expect(bus.mutex).to receive(:synchronize)
            subject.atomically {}
          end

          it 'should take a block and call it exactly once' do
            block = Proc.new {}
            expect(block).to receive(:call).exactly(1).times
            subject.atomically(&block)
          end
        end

        describe '#match' do
          it 'should NOT be atomic' do
            expect(subject).to receive(:atomically).exactly(0).times
            subject.match
          end

          it 'should reset the bus' do
            expect(bus).to receive(:reset)
            subject.match
          end

          it 'should skip rom if it is the only device on the bus' do
            expect(bus).to receive(:write).with(0xCC)
            subject.match
          end

          it 'should try to match ROM, then send its ROM if not alone on the bus' do
            # Just needs to be an array of anything > 1.
            bus.stub(:found_devices) { [1,2] }
            expect(bus).to receive(:write).with(0x55)
            expect(bus).to receive(:write).with([255,255,255,255,255,255,255,255])
            device = Slave.new(bus: bus, address: 0xFFFFFFFFFFFFFFFF)
            device.match
          end
        end

        describe '#copy_scratch' do
          it 'should be atomic' do
            expect(subject).to receive(:atomically).exactly(1).times
            subject.copy_scratch
          end

          it 'should call #match' do
            expect(subject).to receive(:match).exactly(1).times
            subject.copy_scratch
          end

          it 'should send the command' do
            expect(bus).to receive(:write).with(0x48)
            subject.copy_scratch
          end

          it 'should reset the bus after if parasite power is in use' do
            bus.stub(:parasite_power) { true }
            expect(bus).to receive(:reset).exactly(2).times
            subject.copy_scratch
          end
        end

        describe '#read_scratch' do
          it 'should be atomic' do
            expect(subject).to receive(:atomically).exactly(1).times
            subject.read_scratch(9)
          end

          it 'should call #match' do
            expect(subject).to receive(:match).exactly(1).times
            subject.read_scratch(9)
          end

          it 'should send the command' do
            expect(bus).to receive(:write).with(0xBE)
            subject.read_scratch(9)
          end

          it 'should read the right number of bytes' do
            expect(bus).to receive(:read).with(9)
            subject.read_scratch(9)
          end
        end

        describe '#write_scratch' do
          it 'should be atomic' do
            expect(subject).to receive(:atomically).exactly(1).times
            subject.write_scratch([1])
          end

          it 'should call #match' do
            expect(subject).to receive(:match).exactly(1).times
            subject.write_scratch(1)
          end

          it 'should send the command' do
            expect(bus).to receive(:write).with(0x4E)
            subject.write_scratch(1)
          end

          it 'should write the data' do
            expect(bus).to receive(:write).with([1,2,3])
            subject.write_scratch(1,2,3)
          end
        end
      end
    end
  end
end
