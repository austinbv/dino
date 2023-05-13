# encoding: ascii-8bit
# For convenience when validating longer data types.

require_relative '../../test_helper'

class APISPITest < Minitest::Test
  include TestPacker
  
  def connection
    @connection ||= ConnectionMock.new
  end

  def board
    @board ||= Dino::Board.new(connection)
  end
  
  def test_spi_modes
    # Start with mode = 0.
    args = [[], 0, 1000000, 0, :msbfirst]
    assert_equal (pack :uint8, 0b10000000), board.spi_header(*args)[0]

    args[3] = 1
    assert_equal (pack :uint8, 0b10000001), board.spi_header(*args)[0]

    args[3] = 2
    assert_equal (pack :uint8, 0b10000010), board.spi_header(*args)[0]

    args[3] = 3
    assert_equal (pack :uint8, 0b10000011), board.spi_header(*args)[0]

    # Invalid mode = 4.
    assert_raises(ArgumentError) { board.spi_header(*args[3] = 4) }
  end
  
  def test_spi_lsbfirst
    args = [[], 0, 1000000, 0, :lsbfirst]
    assert_equal (pack :uint8, 0b00000000), board.spi_header(*args)[0]
  end

  def test_spi_frequency
    args = [[], 0, 1000000, 0, :msbfirst]
    assert_equal (pack :uint32, 1000000), board.spi_header(*args)[3..6]

    args[2] = 8000000
    assert_equal (pack :uint32, 8000000), board.spi_header(*args)[3..6]
  end
  
  def test_spi_too_many_bytes
    assert_raises(ArgumentError) { board.spi_header(read: 256) }
    assert_raises(ArgumentError) { board.spi_header(write: Array.new(256){0})}
  end
  
  def test_spi_no_bytes
    assert_raises(ArgumentError) { board.spi_transfer(3, read: 0) }
    assert_raises(ArgumentError) { board.spi_listen(3, read: 0) }
  end

  def test_spi_bad_frequency
    assert_raises(ArgumentError) { board.spi_transfer(3, read: 0, frequency: "string") }
  end
  
  def test_spi_transfer
    board
    bytes = [1,2,3,4]
    header = board.spi_header(bytes, 4, 8000000, 2, :lsbfirst)
    aux = header + pack(:uint8, bytes)
    mock = MiniTest::Mock.new.expect  :call, nil,
                                      [Dino::Message.encode(command: 26, pin: 3, aux_message: aux)]
    
    board.stub(:write, mock) do
      args = { write: [1,2,3,4], read: 4, bit_order: :lsbfirst, frequency: 8000000, mode: 2 }
      board.spi_transfer(3, **args)
    end
    mock.verify
  end
  
  def test_spi_listen
    board
    header = board.spi_header([], 8, 1000000, 0, :lsbfirst)
    mock = MiniTest::Mock.new.expect  :call, nil,
                                      [Dino::Message.encode(command: 27, pin: 3, aux_message: header)]
    
    board.stub(:write, mock) do
      board.spi_listen(3, read: 8, bit_order: :lsbfirst)
    end
    mock.verify
  end
  
  def test_spi_stop
    board
    mock = MiniTest::Mock.new.expect :call, nil, [Dino::Message.encode(command: 28, pin: 3)]
    board.stub(:write, mock) do
      board.spi_stop(3)
    end
    mock.verify
  end
end
