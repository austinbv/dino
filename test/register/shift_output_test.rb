require_relative '../test_helper'

class ShiftOutputRegisterTest < Minitest::Test
  def board
    @board ||= BoardMock.new
  end

  def options
    { board: board, pins: { clock: 12, data: 11, latch: 8 } }
  end

  def part
    @part ||= Dino::Register::ShiftOutput.new(options)
  end

  def test_proxies
    assert_equal Dino::DigitalIO::Output,     part.clock.class
    assert_equal Dino::DigitalIO::Output,     part.data.class
    assert_equal Dino::Register::ChipSelect,  part.latch.class
  end

  def test_write
    new_part = Dino::Register::ShiftOutput.new(options.merge(bytes: 2))
    mock = MiniTest::Mock.new.expect :call, nil, [8, 11, 12, [255,127]], bit_order: :msbfirst
    board.stub(:shift_write, mock) do
      new_part.write(255,127)
    end
    mock.verify
  end
end
