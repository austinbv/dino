require 'spec_helper'

module Dino
  module Components
    describe SSD do
      let(:anode) { 11 }
      let(:pins)  { [12,13,3,4,5,10,9] }

      let(:board) do
        mock(:board, digital_write: true, set_pin_mode: true)
      end

      let(:ssd) do
        SSD.new board: board, pins: pins, anode: anode
      end

      describe '#initialize' do
        it 'should raise if it does not receive a pin' do
          expect { SSD.new(board: board, anode: anode) }.to raise_exception
        end

        it 'should raise if it does not receive a board' do
          expect { SSD.new(pins: pins, anode: anode) }.to raise_exception
        end

        it 'should raise if it does not receive a board' do
          expect { SSD.new(board: board, pins: pins) }.to raise_exception
        end

        it 'should set the pins to out' do
          pins.each do |pin|
            board.should_receive(:set_pin_mode).with(pin, :out, nil)
          end

          ssd.after_initialize(anode: anode)
        end

        it "should clear the display" do
          ssd.should_receive(:clear).once
          ssd.after_initialize(anode: anode)
        end

        it "should turn on the display" do
          ssd.should_receive(:on).once
          ssd.after_initialize(anode: anode)
        end
      end

      describe '#clear' do
        it 'should toggle all the seven leds to off' do
          ssd.should_receive(:toggle).exactly(7).with(anything, 0)
          ssd.clear
        end
      end

      describe '#on' do
        it 'should turn the ssd on' do
          board.should_receive(:digital_write).with(anode, Board::HIGH)
          ssd.on
        end
      end

      describe '#off' do
        it 'should turn the ssd off' do
          board.should_receive(:digital_write).with(anode, Board::LOW)
          ssd.off
        end
      end

      describe '#display' do
        it "should scroll on multiple characters" do
          ssd.should_receive(:scroll).with('FOO')
          ssd.display('foo')
        end

        it "should make sure the ssd is turned on" do
          ssd.should_receive(:on)
          ssd.display(1)
        end

        it "should clear the display on unknown character" do
          ssd.should_receive(:clear)
          ssd.display('+')
        end

        it "should toggle all the segments in order to display a character" do
          ssd.should_receive(:toggle).exactly(7)
          ssd.display('7')
        end
      end
    end
  end
end
