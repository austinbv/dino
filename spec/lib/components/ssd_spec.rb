require 'spec_helper'

module Dino
  module Components
    describe SSD do
      let(:txrx)  { mock(:txrx, add_observer: true, handshake: 14, write: true, read: true) }
      let(:board) { Board.new(txrx) }
      let(:pins)  { {anode: 11, a: 12, b: 13, c: 3, d: 4, e: 5, f: 10, g: 9} }
      subject   { SSD.new(board: board, pins: pins) }

      describe '#initialize' do
        it 'should create a digital output for pins a-g' do
          subject

          segments = [:a, :b, :c, :d, :e, :f, :g]
          segments.each { |segment| subject.proxies[segment].class.should == Basic::DigitalOutput}
        end

        it "should clear the display" do
          SSD.any_instance.should_receive(:clear).once
          SSD.new(board: board, pins: pins)
        end

        it "should turn on the display" do
          SSD.any_instance.should_receive(:on).once
          SSD.new(board: board, pins: pins)
        end
      end

      describe '#clear' do
        it 'should toggle all the seven leds to off' do
          segments = [:a, :b, :c, :d, :e, :f, :g]
          segments.each { |segment| subject.proxies[segment].should_receive(:high) }

          subject.clear
        end
      end

      describe '#on' do
        it 'should turn the ssd on' do
          subject.anode.should_receive(:digital_write).with(board.high)
          subject.on
        end
      end

      describe '#off' do
        it 'should turn the ssd off' do
          subject.anode.should_receive(:digital_write).with(board.low)
          subject.off
        end
      end

      describe '#display' do
        it "should scroll on multiple characters" do
          subject.should_receive(:scroll).with('foo')
          subject.display('foo')
        end

        it "should make sure the ssd is turned on" do
          subject.should_receive(:on)
          subject.display(1)
        end

        it "should clear the display on unknown character" do
          subject.should_receive(:clear)
          subject.display('+')
        end
      end

      describe 'with a cathode' do
        it 'should invert the logic'
      end
    end
  end
end
