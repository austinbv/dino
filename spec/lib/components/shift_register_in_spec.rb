require 'spec_helper'

module Dino
  module Components
    describe ShiftRegisterIn do
      include BoardMock
      let(:options) { { board: board, pins: {clock: 12, data: 11, latch: 8} } }
      subject { ShiftRegisterIn.new(options)  }

      describe '#initialize' do
        it 'should create DigitalOutput instances for clock and latch pins' do
          expect(subject.clock.class).to eq(Basic::DigitalOutput)
          expect(subject.latch.class).to eq(Basic::DigitalOutput)
        end

        it 'should create an AnalogInput instance for data pin' do
          expect(subject.data.class).to eq(Basic::AnalogInput)
        end

        it 'should set the number of bytes when given as option' do
          subject = ShiftRegisterIn.new(options.merge(bytes:2))
          expect(subject.instance_variable_get(:@bytes)).to eq(2)
        end

        it 'should default the preclock_high variable to 0' do
          expect(subject.instance_variable_get(:@preclock_high)).to eq(0)
        end

        it 'should set @preclock_high to 1 if given anything other than 0' do
          subject = ShiftRegisterIn.new(options.merge(preclock_high: :yes))
          expect(subject.instance_variable_get(:@preclock_high)).to eq(1)
        end
      end

      describe '#read' do
        before(:each) { subject }

        it 'should send message for single byte in the request format the board expects' do
          expect(board).to receive(:write).with "23.11.12.#{[8,0,1].pack('C*')}\n"
          subject.read
        end

        it 'should request the correct number of bytes to be read' do
          subject = ShiftRegisterIn.new(options.merge(bytes: 2))
          expect(board).to receive(:write).with "23.11.12.#{[8,0,2].pack('C*')}\n"
          subject.read
        end

        it 'should request clock pin to go high before reading if set' do
          subject = ShiftRegisterIn.new(options.merge(preclock_high: 1))
          expect(board).to receive(:write).with "23.11.12.#{[8,1,1].pack('C*')}\n"
          subject.read
        end
      end

      describe '#update' do
        before(:each) { subject }

        it 'should bubble #update from the data pin up to itself' do
          expect(subject).to receive(:update).once.with("127,255")
          subject.data.update("127,255")
        end

        it 'should update @state with data converted to array of 0/1 integers' do
          subject.update("127")
          expect(subject.instance_variable_get(:@state)).to eq([0,1,1,1,1,1,1,1])

          subject = ShiftRegisterIn.new(options.merge(bytes: 2))
          subject.update("127,255")
          expect(subject.instance_variable_get(:@state)).to eq([0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1])
        end

        it 'should pass data to the callbacks as an array of 0/1 integers' do
          @callback = Proc.new{}
          subject.add_callback(&@callback)
          expect(@callback).to receive(:call).once.with([0,1,1,1,1,1,1,1])
          subject.update("127")
        end
      end
    end
  end
end
