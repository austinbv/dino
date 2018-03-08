require 'dino'
require 'board_mock'
require 'minitest/autorun'

class SoftwareSerialTest < MiniTest::Test
  def board
    @board ||= BoardMock.new
  end

  def part
    @part ||= Dino::Components::SoftwareSerial.new board: board, pins: { rx: 10, tx: 11 }, baud: 4800
  end

  def test_initialize
    mock = MiniTest::Mock.new
    mock.expect :call, nil, ["12..0.10,11\n"]
    mock.expect :call, nil, ["12..1.4800\n"]
    board.stub(:write, mock) do
      part
    end
    mock.verify
  end

  def test_puts
    part
    mock = MiniTest::Mock.new
    mock.expect :call, nil, ["12..3.Testing\n"]
    board.stub(:write, mock) do
      part.puts("Testing")
    end
    mock.verify
  end
end
