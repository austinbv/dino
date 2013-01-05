require 'spec_helper'

module Dino
  describe TxRx::Telnet do
    describe '#io' do
      it 'should use the existing io instance if set'
      it 'should raise a BoardNotFound exception if it cannot connect to the server'
    end

    describe '#io=' do
      it 'should set io to a new telnet connection with the specified host and port'
    end

    describe '#read' do
      it 'should create a new thread'
      it 'should get messages from the device'
    end

    describe '#close_read' do
      it 'should kill the reading thread'
    end

    describe '#write' do
      it 'should write to the device'
    end
  end
end
