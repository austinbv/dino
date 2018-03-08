require 'dino'
require 'board_mock'
require 'minitest/autorun'

class RGBLedTest < MiniTest::Test
 def board
    @board ||= BoardMock.new
  end

  def options
    { board: board, pins: { red: 1, green: 2, blue: 3 } }
  end

  def part
    @part ||= Dino::Components::RGBLed.new(options)
  end

  def test_proxies
    assert_equal Dino::Components::Basic::AnalogOutput, part.red.class
    assert_equal Dino::Components::Basic::AnalogOutput, part.green.class
    assert_equal Dino::Components::Basic::AnalogOutput, part.blue.class
  end

  def test_write
    red_mock = MiniTest::Mock.new.expect :write, nil, [0]
    green_mock = MiniTest::Mock.new.expect :write, nil, [128]
    blue_mock = MiniTest::Mock.new.expect :write, nil, [0]

    part.stub(:red, red_mock) do
      part.stub(:green, green_mock) do
        part.stub(:blue, blue_mock) do
          part.write [0, 128, 0]
        end
      end
    end
    red_mock.verify
    green_mock.verify
    blue_mock.verify
  end

  def test_color_array
    mock = MiniTest::Mock.new.expect :call, nil, [[128,0,0]]
    part.stub(:write, mock) do
      part.color = [128,0,0]
    end
    mock.verify
  end

  def test_color_names
    colors = Dino::Components::RGBLed::COLORS

    mock = MiniTest::Mock.new
    colors.each_value do |color|
      mock.expect :call, nil, [color]
      mock.expect :call, nil, [color]
    end

    part.stub(:write, mock) do
      colors.each_key do |key|
        part.color = key
        part.color = key.to_s
      end
    end
    mock.verify
  end
end
