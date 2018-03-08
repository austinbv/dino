require 'dino'
require 'board_mock'
require 'minitest/autorun'

class SSDTest < MiniTest::Test
 def board
    @board ||= BoardMock.new
  end

  def options
    { board: board,
      pins: {anode: 11, a: 12, b: 13, c: 3, d: 4, e: 5, f: 10, g: 9} }
  end

  def part
    @part ||= Dino::Components::SSD.new(options)
  end

  def test_proxies
    segments = [:a, :b, :c, :d, :e, :f, :g]
    segments.each do |segment|
      assert_equal Dino::Components::Basic::DigitalOutput, part.proxies[segment].class
    end
  end

  def test_initialize_clear
    mock = MiniTest::Mock.new.expect :call, nil
    part.stub(:clear, mock) do
      part.send(:initialize, options)
    end
    mock.verify
  end

  def test_initialize_on
    mock = MiniTest::Mock.new.expect :call, nil
    part.stub(:on, mock) do
      part.send(:initialize, options)
    end
    mock.verify
  end

  def test_on
    mock = MiniTest::Mock.new.expect :high, nil
    part.stub(:anode, mock) do
      part.on
    end
    mock.verify
  end

  def test_off
    mock = MiniTest::Mock.new.expect :low, nil
    part.stub(:anode, mock) do
      part.off
    end
    mock.verify
  end

  def test_scroll
    mock = MiniTest::Mock.new.expect :call, nil, ['foo']
    part.stub(:scroll, mock) do
      part.display('foo')
    end
    mock.verify
  end

  def test_display_ensures_on
    mock = MiniTest::Mock.new.expect :call, nil
    part.stub(:on, mock) do
      part.display(1)
    end
    mock.verify
  end

  def test_display_clears_if_unknown_char
    mock = MiniTest::Mock.new.expect :call, nil
    part.stub(:clear, mock) do
      part.display('+')
    end
    mock.verify
  end
  # Test with cathode
end
