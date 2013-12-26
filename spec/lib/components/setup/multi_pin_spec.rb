require 'spec_helper'

module Dino
  module Components
    module Setup
      describe MultiPin do
        let(:txrx) { mock(:txrx, add_observer: true, handshake: 14, write: true, read: true) }
        let(:board) { Board.new(txrx) }
        let(:options) { { pins: {red: 9, blue: 10}, board: board } }
        class MultiPinComponent; include MultiPin; end
        subject { MultiPinComponent.new(options) }

        describe "::require_pins" do
          it 'should add the pins to the @@required_pins class variable'
        end

        describe "::proxy_pins" do
          it 'should also call ::require_pins unless the pins are optional'
          it 'should add the pins to the @@proxied_pins class variable'
        end

        describe '#initialize' do
          it 'should require every pin in the @@require_pin class variable'
          it 'should create proxies for each of the pins in @@proxy_pins'
        end
      end
    end
  end
end
