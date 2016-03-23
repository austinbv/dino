require 'spec_helper'

module Dino
  module Components
    describe SSD do
      include BoardMock
      let(:pins)  { {anode: 11, a: 12, b: 13, c: 3, d: 4, e: 5, f: 10, g: 9} }
      subject   { SSD.new(board: board, pins: pins) }

      describe '#initialize' do
        it 'should create a digital output for pins a-g' do
          subject

          segments = [:a, :b, :c, :d, :e, :f, :g]
          segments.each do |segment|
            expect(subject.proxies[segment].class).to equal(Basic::DigitalOutput)
          end
        end

        it "should clear the display" do
          expect(subject).to receive(:clear).once
          subject.send(:initialize, {board: board, pins: pins})
        end

        it "should turn on the display" do
          expect(subject).to receive(:on).once
          subject.send(:initialize, {board: board, pins: pins})
        end
      end

      describe '#clear' do
        it 'should toggle all the seven leds to off' do
          segments = [:a, :b, :c, :d, :e, :f, :g]
          segments.each do |segment|
            expect(subject.proxies[segment]).to receive(:high)
          end

          subject.clear
        end
      end

      describe '#on' do
        it 'should turn the ssd on' do
          expect(subject.anode).to receive(:digital_write).with(board.high)
          subject.on
        end
      end

      describe '#off' do
        it 'should turn the ssd off' do
          expect(subject.anode).to receive(:digital_write).with(board.low)
          subject.off
        end
      end

      describe '#display' do
        it "should scroll on multiple characters" do
          expect(subject).to receive(:scroll).with('foo')
          subject.display('foo')
        end

        it "should make sure the ssd is turned on" do
          expect(subject).to receive(:on)
          subject.display(1)
        end

        it "should clear the display on unknown character" do
          expect(subject).to receive(:clear)
          subject.display('+')
        end
      end

      describe 'with a cathode' do
        it 'should invert the logic'
      end
    end
  end
end
