require 'spec_helper'

module Dino
  module Components
    describe RgbLed do
      include BoardMock
      let(:options) { { board: board, pins: {red: 1, green: 2, blue: 3} } }
      subject { RgbLed.new(options) }

      describe '#initialize' do
        it 'should create a BaseOutput instance for each pin' do
          led = RgbLed.new(options)

          expect(led.red.class).to eq(Basic::AnalogOutput)
          expect(led.green.class).to eq(Basic::AnalogOutput)
          expect(led.blue.class).to eq(Basic::AnalogOutput)
        end
      end

      describe '#write' do
        it 'should write the elements of the array to red, green and blue' do
          expect(subject.red).to receive(:write).with(0)
          expect(subject.green).to receive(:write).with(128)
          expect(subject.blue).to receive(:write).with(0)

          subject.write [0, 128, 0]
        end
      end

      describe '#color=' do
        it 'should write an array of values' do
          expect(subject).to receive(:write).with([128, 0, 0])
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
          colors.each_value { |color| expect(subject).to receive(:write).with(color).twice }

          colors.each_key { |key| subject.color = key }
          colors.each_key { |key| subject.color = key.to_s }
        end
      end

      describe '#cycle' do
        it 'should cycle through the 3 base colors' do
          expect_any_instance_of(Array).to receive(:cycle).and_yield(:red).and_yield(:green).and_yield(:blue)
          expect(subject).to receive(:color=).with(:red)
          expect(subject).to receive(:color=).with(:green)
          expect(subject).to receive(:color=).with(:blue)
          subject.cycle
        end
      end
    end
  end
end
