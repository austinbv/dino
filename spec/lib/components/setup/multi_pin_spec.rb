require 'spec_helper'

module Dino
  module Components
    module Setup
      describe MultiPin do
        include BoardMock
        let(:options) { { pins: {one: 9, two: 10, maybe: 11}, board: board } }

        class MultiPinComponent
          include MultiPin
          require_pin :one
          proxy_pin   two:   Basic::DigitalOutput
          proxy_pin   maybe: Basic::DigitalInput, optional: true
        end
        subject { MultiPinComponent.new(options) }

        describe "::require_pins" do
          it 'should add required pins to the @@required_pins class variable' do
            MultiPinComponent.class_eval('@@required_pins').should == [:one, :two]
          end
        end

        describe "::proxy_pins" do
          it 'should automatically require the pin unless :optional is true' do
            MultiPinComponent.class_eval('@@required_pins').should == [:one, :two]
          end

          it 'should add the pins to the @@proxied_pins class variable with the right classes' do
            MultiPinComponent.class_eval('@@proxied_pins').should == {two: Basic::DigitalOutput, maybe: Basic::DigitalInput}
          end
        end

        describe '#validate_pins' do
          it 'should raise an error for any required pin that is missing' do
            expect {
              MultiPinComponent.new(board: board, pins: {one: 9, maybe: 11})
            }.to raise_exception(/two/)
          end

          it 'should not raise errors for optional pins that are missing' do
            expect {
              MultiPinComponent.new(board: board, pins: {one: 9, two: 10})
            }.to_not raise_exception
          end
        end

        describe '#build_proxies' do
          it 'should create the correct proxy subcomponents' do
            subject.proxies[:two].class.should == Basic::DigitalOutput
            subject.proxies[:maybe].class.should == Basic::DigitalInput
          end

          it 'should create an attr_accessor for each proxy' do
            subject.two.class.should == Basic::DigitalOutput
            subject.maybe.class.should == Basic::DigitalInput
          end

          it 'should attach the subcomponents to the right pins' do
            subject.two.pin.should == 10
            subject.maybe.pin.should == 11
          end
        end

        describe '#states' do
          it 'should return a hash with the state of each subcomponent' do
            subject.two.high
            subject.state.should == {two: board.high, maybe: nil}
          end
        end
      end
    end
  end
end
