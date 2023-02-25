require 'test_helper'

class RegisterShiftInTest < Minitest::Test
  def board
    @board ||= BoardMock.new
  end

  def options
    { board: board, pins: { clock: 12, data: 11, latch: 8 } }
  end

  def part
    @part ||= Dino::Components::Register::ShiftIn.new(options)
  end

  def test_proxies
    assert_equal Dino::Components::Basic::DigitalOutput, part.clock.class
    assert_equal Dino::Components::Basic::DigitalInput,  part.data.class
    assert_equal Dino::Components::Register::Select,     part.latch.class
  end

  def test_rising_clock
    assert_equal part.rising_clock, false
    new_part = Dino::Components::Register::ShiftIn.new(options.merge(rising_clock: :yes))
    assert_equal true, new_part.rising_clock
  end

  def test_read
    mock = MiniTest::Mock.new
    mock.expect :call, nil, [8, 11, 12, 2], preclock_high: false, bit_order: :lsbfirst
    mock.expect :call, nil, [8, 11, 12, 2], preclock_high: true, bit_order: :msbfirst
    board.stub(:shift_read, mock) do
      new_part = Dino::Components::Register::ShiftIn.new options.merge(bytes: 2)
      new_part.read
      
      new_part = Dino::Components::Register::ShiftIn.new options.merge(bytes: 2, rising_clock: true, bit_order: :msbfirst)
      new_part.read
    end
    mock.verify
  end
  
  def test_listen
    mock = MiniTest::Mock.new
    mock.expect :call, nil, [8, 11, 12, 2], preclock_high: false, bit_order: :lsbfirst
    mock.expect :call, nil, [8, 11, 12, 2], preclock_high: true, bit_order: :msbfirst
    board.stub(:shift_listen, mock) do
      new_part = Dino::Components::Register::ShiftIn.new options.merge(bytes: 2)
      new_part.listen
      
      new_part = Dino::Components::Register::ShiftIn.new options.merge(bytes: 2, rising_clock: true, bit_order: :msbfirst)
      new_part.listen
    end
    mock.verify
  end
  
  def test_stop
    mock = MiniTest::Mock.new.expect :call, nil, [8]
    board.stub(:shift_stop, mock) do
      new_part = Dino::Components::Register::ShiftIn.new(options.merge(bytes: 2, rising_clock: true))
      new_part.stop
    end
    mock.verify
  end
  
  def test_gets_reads_through_latch_pin
    mock = MiniTest::Mock.new.expect :call, nil, ["127,255"]
    part.stub(:update, mock) do
      part.latch.update "127,255"
    end
    mock.verify
  end
end
