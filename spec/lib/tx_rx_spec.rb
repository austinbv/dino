require 'spec_helper'

module Dino
  describe TxRx do
    it { should be }

    describe '#initialize' do
      it 'should set first_write to false' do
        TxRx.new.instance_variable_get(:@first_write).should == false
      end
    end

    describe '#locate_board' do
      it 'should find a tty.usb board'
    end
  end
end