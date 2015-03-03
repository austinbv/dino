require 'spec_helper'

module Dino
  describe Dino::Message do
    describe '.encode' do

      it 'should require a command' do
        expect { Dino::Message.encode }.to raise_exception(/command/)
        expect { Dino::Message.encode(command:90) }.to_not raise_exception
      end

      it 'should not allow commands longer than 4 digits' do
        expect { Dino::Message.encode(command:90000) }.to raise_exception(/four/)
      end

      it 'should not allow pins longer than 4 digits' do
        expect { Dino::Message.encode(command:90, pin:90000) }.to raise_exception(/four/)
      end

      it 'should not allow values longer than 4 digits' do
        expect { Dino::Message.encode(command:90, value:90000) }.to raise_exception(/four/)
      end

      it 'should not allow values longer than 4 digits' do
        expect { Dino::Message.encode(command:90, aux_message: "0" * 256) }.to raise_exception(/255/)
      end

      it 'should build messages correctly' do
        Dino::Message.encode(command: 1, pin: 1, value: 1).should == "1.1.1\n"
        Dino::Message.encode(command: 1, pin: 1).should == "1.1\n"
        Dino::Message.encode(command: 1, value: 1).should == "1..1\n"
        Dino::Message.encode(command: 1).should == "1\n"
        Dino::Message.encode(command: 1, pin: 1, value: 1, aux_message: "Some Text").should == "1.1.1.Some Text\n"
        Dino::Message.encode(command: 1, aux_message: "Some Text").should == "1...Some Text\n"
        Dino::Message.encode(command: 1, value: 1, aux_message: "Some Text").should == "1..1.Some Text\n"
      end

      it 'should escape newlines inside aux message' do
        Dino::Message.encode(command: 1, aux_message: "line1\nline2").should == "1...line1\\\nline2\n"
      end

      it 'should escape backslashes inside aux message' do
        Dino::Message.encode(command: 1, aux_message: "line1\\line2").should == "1...line1\\\\line2\n"
      end
    end
  end
end
