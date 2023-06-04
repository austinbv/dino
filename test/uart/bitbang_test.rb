require_relative '../test_helper'

class UARTBitBangTest < MiniTest::Test
  include TestPacker

  def board
    @board ||= BoardMock.new
  end

  def part
    @part ||= Dino::UART::BitBang.new board: board, pins: { rx: 10, tx: 11 }, baud: 4800
  end

  def test_initialize
    mock = MiniTest::Mock.new
    # Set RX to input
    mock.expect :call, nil, ["0.10.1\n"]
    # Start BB UART
    aux = pack(:uint32, 4800) + pack(:uint8, 0b11000000)
    mock.expect :call, nil, ["12.11.10.#{aux}\n"]

    board.stub(:write, mock) do
      part
    end
    mock.verify
  end

  def test_write
    part
    mock = MiniTest::Mock.new
    mock.expect :call, nil, ["13..8.Testing\\\n\n"]
    board.stub(:write, mock) do
      part.write("Testing\n")
    end
    mock.verify
  end
end
