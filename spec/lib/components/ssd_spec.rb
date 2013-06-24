require 'spec_helper'

module Dino
  module Components
    describe SSD do
      let(:txrx)  { mock(:txrx, add_observer: true, handshake: 14, write: true, read: true) }
      let(:board) { Board.new(txrx) }
      let(:anode) { 11 }
      let(:pins)  { [12,13,3,4,5,10,9] }
      subject   { SSD.new(board: board, pins: pins, anode: anode) }

      describe '#initialize' do
        it 'should raise if it does not receive an anode' do
          expect { SSD.new(board: board, pins: pins) }.to raise_exception
        end

        it 'should create a Core::BaseOutput for the anode and each pin' do
          subject

          subject.anode.class.should == Core::BaseOutput
          subject.pins.each { |pin| pin.class.should == Core::BaseOutput}
        end

        it "should clear the display" do
          SSD.any_instance.should_receive(:clear).once
          SSD.new(board: board, pins: pins, anode: anode)
        end

        it "should turn on the display" do
          SSD.any_instance.should_receive(:on).once
          SSD.new(board: board, pins: pins, anode: anode)
        end
      end

      describe '#clear' do
        it 'should toggle all the seven leds to off' do
          subject.should_receive(:toggle).exactly(7).with(anything, 0)
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
          subject.should_receive(:scroll).with('FOO')
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

        it "should toggle all the segments in order to display a character" do
          subject.should_receive(:toggle).exactly(7)
          subject.display('7')
        end
      end
    end
  end
end
