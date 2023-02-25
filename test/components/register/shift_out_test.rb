require 'test_helper'

class RegisterShiftOutTest < Minitest::Test
  def board
    @board ||= BoardMock.new
  end

  def options
    { board: board, pins: { clock: 12, data: 11, latch: 8 } }
  end

  def part
    @part ||= Dino::Components::Register::ShiftOut.new(options)
  end

  def test_proxies
    assert_equal Dino::Components::Basic::DigitalOutput, part.clock.class
    assert_equal Dino::Components::Basic::DigitalOutput, part.data.class
    assert_equal Dino::Components::Register::Select,     part.latch.class
  end

  def test_write
    new_part = Dino::Components::Register::ShiftOut.new(options.merge(bytes: 2))
    mock = MiniTest::Mock.new.expect :call, nil, [8, 11, 12, [255,127]], bit_order: :msbfirst
    board.stub(:shift_write, mock) do
      new_part.write(255,127)
    end
    mock.verify
  end
end
