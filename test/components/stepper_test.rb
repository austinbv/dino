require 'test_helper'

class StepperTest < MiniTest::Test
  def board
    @board ||= BoardMock.new
  end

  def part
    @part ||= Dino::Components::Stepper.new board: board,
                                            pins: {step: 9, direction: 10}
  end

  def test_initialize
    assert_equal Dino::Components::Basic::DigitalOutput, part.step.class
    assert_equal Dino::Components::Basic::DigitalOutput, part.direction.class
  end

  def test_step_cw
    dir_mock = MiniTest::Mock.new.expect :low, nil
    step_mock = MiniTest::Mock.new
    step_mock.expect :high, nil
    step_mock.expect :low, nil

    part.stub(:direction, dir_mock) do
      part.stub(:step, step_mock) do
        part.step_cw
      end
    end
    dir_mock.verify
    step_mock.verify
  end

  def test_step_cc
    dir_mock = MiniTest::Mock.new.expect :high, nil
    step_mock = MiniTest::Mock.new
    step_mock.expect :high, nil
    step_mock.expect :low, nil

    part.stub(:direction, dir_mock) do
      part.stub(:step, step_mock) do
        part.step_cc
      end
    end
    dir_mock.verify
    step_mock.verify
  end
end
