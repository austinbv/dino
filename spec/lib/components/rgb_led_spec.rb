require 'spec_helper'

module Dino
  module Components
    describe RgbLed do
      let(:txrx) { mock(:txrx, add_observer: true, handshake: 14, write: true, read: true) }
      let(:board) { Board.new(txrx) }
      let(:options) { { board: board, pins: {red: 1, green: 2, blue: 3} } }
      subject { RgbLed.new(options) }

      describe '#initialize' do
        it 'should create a BaseOutput instance for each pin' do
          led = RgbLed.new(options)
          
          led.red.class.should == Core::BaseOutput
          led.green.class.should == Core::BaseOutput
          led.blue.class.should == Core::BaseOutput
        end
      end

      describe '#write' do
        it 'should write the elements of the array to red, green and blue' do
          subject.red.should_receive(:write).with(0)
          subject.green.should_receive(:write).with(128)
          subject.blue.should_receive(:write).with(0)

          subject.write [0, 128, 0]
        end
      end

      describe '#color=' do
        it 'should write an array of values' do
          subject.should_receive(:write).with([128, 0, 0])
          subject.color = [128, 0, 0]
        end

        it 'should look up named colors in COLORS whether passed in as symbol or string' do
          colors = {
            red:     [255, 000, 000],
            green:   [000, 255, 000],
            blue:    [000, 000, 255],
            cyan:    [000, 255, 255],
            yellow:  [255, 255, 000],
            magenta: [255, 000, 255],
            white:   [255, 255, 255],
            off:     [000, 000, 000]
          }
          colors.each_value { |color| subject.should_receive(:write).with(color).twice }

          colors.each_key { |key| subject.color = key }
          colors.each_key { |key| subject.color = key.to_s }
        end
      end

      describe '#cycle' do
        it 'should cycle through the 3 base colors' do
          Array.any_instance.should_receive(:cycle).and_yield(:red).and_yield(:green).and_yield(:blue)
          subject.should_receive(:color=).with(:red)
          subject.should_receive(:color=).with(:green)
          subject.should_receive(:color=).with(:blue)
          subject.cycle
        end
      end
    end
  end
end
