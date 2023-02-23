# encoding: ascii-8bit
# For convenience when validating longer data types.

require 'test_helper'

class APISPITest < Minitest::Test
  include Dino::API::Helper
  
  def txrx
    @txrx ||= TxRxMock.new
  end

  def board
    @board ||= Dino::Board.new(txrx)
  end
  
  def test_spi_modes
    assert_equal (board.spi_header(mode: nil)[0][0]), (pack :uint8, 0b10000000)
    assert_equal (board.spi_header(mode: 1  )[0][0]), (pack :uint8, 0b10000001)
    assert_equal (board.spi_header(mode: 2  )[0][0]), (pack :uint8, 0b10000010)
    assert_equal (board.spi_header(mode: 3  )[0][0]), (pack :uint8, 0b10000011)
    assert_raises(ArgumentError) { board.spi_header(mode: 4) }
  end
  
  def test_spi_lsbfirst
    assert_equal (board.spi_header(bit_order: :lsbfirst)[0][0]), (pack :uint8, 0b00000000)
  end

  def test_spi_frequency
    assert_equal (board.spi_header(frequency: nil    )[0][3..6]), (pack :uint32, 3000000)
    assert_equal (board.spi_header(frequency: 8000000)[0][3..6]), (pack :uint32, 8000000)
  end
  
  def test_spi_too_many_bytes
    assert_raises(ArgumentError) { board.spi_header(read: 256) }
    assert_raises(ArgumentError) { board.spi_header(write: Array.new(256){0})}
  end
  
  def test_spi_no_bytes
    assert_raises(ArgumentError) { board.spi_transfer(3, read: 0) }
    assert_raises(ArgumentError) { board.spi_listen(3, read: 0) }
  end
  
  def test_spi_transfer
    board
    options = { write: [1,2,3,4], read: 4, bit_order: :lsbfirst, frequency: 8000000, mode: 2 }
    header = board.spi_header(options)[0]
    aux = header + pack(:uint8, options[:write])
    
    mock = MiniTest::Mock.new
    mock.expect :call, nil, [Dino::Message.encode(command: 26, pin: 3, aux_message: aux)]
    
    board.stub(:write, mock) do
      board.spi_transfer(3, options)
    end
    mock.verify
  end
  
  def test_spi_listen
    board
    options = { read: 8, bit_order: :lsbfirst }
    header = board.spi_header(options)[0]
    
    mock = MiniTest::Mock.new
    mock.expect :call, nil, [Dino::Message.encode(command: 27, pin: 3, aux_message: header)]
    
    board.stub(:write, mock) do
      board.spi_listen(3, options)
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
