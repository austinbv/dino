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
            expect(MultiPinComponent.class_eval('@@required_pins')).to eq([:one, :two])
          end
        end

        describe "::proxy_pins" do
          it 'should automatically require the pin unless :optional is true' do
            expect(MultiPinComponent.class_eval('@@required_pins')).to eq([:one, :two])
          end

          it 'should add the pins to the @@proxied_pins class variable with the right classes' do
            expect(MultiPinComponent.class_eval('@@proxied_pins')).to eq({two: Basic::DigitalOutput, maybe: Basic::DigitalInput})
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
            expect(subject.proxies[:two].class).to equal(Basic::DigitalOutput)
            expect(subject.proxies[:maybe].class).to equal(Basic::DigitalInput)
          end

          it 'should create an attr_accessor for each proxy' do
            expect(subject.two).to equal(subject.proxies[:two])
            expect(subject.maybe).to equal(subject.proxies[:maybe])
          end

          it 'should attach the subcomponents to the right pins' do
            expect(subject.two.pin).to eq(10)
            expect(subject.maybe.pin).to eq(11)          end
        end

        describe '#states' do
          it 'should return a hash with the state of each subcomponent' do
            subject.two.high
            expect(subject.state).to eq({two: board.high, maybe: nil})
          end
        end
      end
    end
  end
end
