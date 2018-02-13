require 'spec_helper'

module Dino
  module Components
    module Register
      describe ShiftIn do
        include BoardMock
        let(:options) { { board: board, pins: {clock: 12, data: 11, latch: 8} } }
        subject { ShiftIn.new(options)  }

        describe '#initialize' do
          it 'should create a DigitalOutput instance for clock pin' do
            expect(subject.clock.class).to eq(Basic::DigitalOutput)
          end

          it 'should create a DigitalInput instance for data pin' do
            expect(subject.data.class).to eq(Basic::DigitalInput)
          end

          it 'should create a Register::Select instance for latch pin' do
            expect(subject.latch.class).to eq(Register::Select)
          end

          it 'should set the number of bytes when given as option' do
            subject = ShiftIn.new(options.merge(bytes:2))
            expect(subject.instance_variable_get(:@bytes)).to eq(2)
          end

          it 'should default the rising_clock variable to 0' do
            expect(subject.instance_variable_get(:@rising_clock)).to eq(false)
          end

          it 'should set @rising_clock to true if given anything other than false' do
            subject = ShiftIn.new(options.merge(rising_clock: :yes))
            expect(subject.instance_variable_get(:@rising_clock)).to eq(true)
          end
        end

        describe '#read' do
          before(:each) { subject }

          it 'should send message for single byte in the request format the board expects' do
            expect(board).to receive(:write).with "22.8.1.#{[11,12,0].pack('C*')}\n"
            subject.read
          end

          it 'should request the correct number of bytes to be read' do
            subject = ShiftIn.new(options.merge(bytes: 2))
            expect(board).to receive(:write).with "22.8.2.#{[11,12,0].pack('C*')}\n"
            subject.read
          end

          it 'should request clock pin to go high before reading if set' do
            subject = ShiftIn.new(options.merge(rising_clock: 1))
            expect(board).to receive(:write).with "22.8.1.#{[11,12,1].pack('C*')}\n"
            subject.read
          end
        end

        describe '#update' do
          before(:each) { subject }

          it 'should bubble #update from the latch pin up to itself' do
            expect(subject).to receive(:update).once.with("127,255")
            subject.latch.update("127,255")
          end

          it 'should update @state with data converted to array of 0/1 integers' do
            subject.update("127")
            expect(subject.instance_variable_get(:@state)).to eq([0,1,1,1,1,1,1,1])

            subject = ShiftIn.new(options.merge(bytes: 2))
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
end
