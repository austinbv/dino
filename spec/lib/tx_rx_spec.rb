require 'spec_helper'

module Dino
  describe TxRx do
    it { should be }

    describe '#initialize' do
      it 'should set first_write to false' do
        TxRx.new.instance_variable_get(:@first_write).should == true
      end
    end

    describe '#io' do
      it 'should be tested'
    end

    describe '#read' do
      it 'should be tested'
    end

    describe '#close_read' do
      it 'should be tested'
    end

    describe '#write' do
      it 'should be tested'
    end

    it 'should find a tty.usb board'
  end
end