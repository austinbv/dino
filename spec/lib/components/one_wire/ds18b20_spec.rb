require 'spec_helper'

module Dino
  module Components
    module OneWire
      describe DS18B20 do
        include BoardMock
        let(:options) { { board: board, pin: 7 } }
        subject { DS18B20.new(options)  }

        describe '#decode' do
          it 'should decode values matching the datasheet and convert C to F' do
            expect(subject.decode(0b0000_0111, 0b1101_0000)).to eq(celsius: 125, farenheit: 257)
            expect(subject.decode(0b0000_0000, 0b0000_0000)).to eq(celsius: 0, farenheit: 32)
            expect(subject.decode(0b1111_1111, 0b0101_1110)).to eq(celsius: -10.125, farenheit: 13.775)
            expect(subject.decode(0b1111_1100, 0b1001_0000)).to eq(celsius: -55, farenheit: -67)
          end
        end
      end
    end
  end
end
