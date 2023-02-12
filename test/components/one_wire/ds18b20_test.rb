require 'test_helper'

class DS18B20Test < MiniTest::Test
  def bus
    @bus ||= Dino::Components::OneWire::Bus.new(board: BoardMock.new, pin: 1)
  end

  def part
    @part ||= Dino::Components::OneWire::DS18B20.new(bus: bus, address: 0xFFFFFFFFFFFFFFFF)
  end

  def test_decode_temperatures
    assert_equal({ celsius: 125, fahrenheit: 257 },
                 part.decode_temperature([0b1101_0000,0b0000_0111]))
    assert_equal({ celsius: 0, fahrenheit: 32 },
                 part.decode_temperature([0b0000_0000,0b0000_0000]))
    assert_equal({ celsius: -10.125, fahrenheit: 13.775 },
                 part.decode_temperature([0b0101_1110,0b1111_1111]))
    assert_equal({ celsius: -55, fahrenheit: -67 },
                 part.decode_temperature([0b1001_0000,0b1111_1100]))
  end

  def test_decode_resolution
    assert_equal 12, part.decode_resolution([0,0,0,0,0b01100000])
    assert_equal 11, part.decode_resolution([0,0,0,0,0b01000000])
    assert_equal 10, part.decode_resolution([0,0,0,0,0b00100000])
    assert_equal  9, part.decode_resolution([0,0,0,0,0b00000000])
  end

  def test_set_convert_time
    part.instance_variable_set(:@resolution, 9)
    part.set_convert_time
    assert_equal 0.09375, part.instance_variable_get(:@convert_time)
    part.instance_variable_set(:@resolution, 12)
    part.set_convert_time
    assert_equal 0.75, part.instance_variable_get(:@convert_time)
  end

  # test resolution=

  def test_convert_is_atomic
    mock = MiniTest::Mock.new.expect(:call, nil)
    part.stub(:atomically, mock) { part.convert }
  end

  def test_convert_matches_first
    mock = MiniTest::Mock.new.expect(:call, nil)
    part.stub(:match, mock) { part.convert}
  end

  def test_convert_sends_the_command
    mock = MiniTest::Mock.new
    mock.expect(:call, nil, [0xCC])
    mock.expect(:call, nil, [0x44])
    bus.stub(:write, mock) { part.convert }
  end

  def test_convert_sets_max_convert_time_first
    part.convert
    assert_equal 0.75, part.instance_variable_get(:@convert_time)
  end

  def test_convert_sleeps_for_convert_time
    mock = MiniTest::Mock.new.expect(:call, nil, [0.75])
    part.stub(:sleep, mock) do
      part.convert
    end
  end

  def test_convert_sleeps_inside_lock_if_parasite_power
    bus.instance_variable_set(:@parasite_power, true)
    Thread.new do
      sleep 0.5
      assert_equal true, bus.mutex.locked?
    end
    part.convert
  end
end
