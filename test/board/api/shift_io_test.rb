# encoding: ascii-8bit
# For convenience when validating longer data types.

require_relative '../../test_helper'

class APIShiftIOTest < Minitest::Test
  include Dino::Board::API::Helper
  
  def connection
    @connection ||= ConnectionMock.new
  end

  def board
    @board ||= Dino::Board.new(connection)
  end
  
  def test_shift_settings
    settings1 = pack :uint8, [6, 7, 0b00]
    settings2 = pack :uint8, [4, 5, 0b01]
    settings3 = pack :uint8, [4, 5, 0b10]
    settings4 = pack :uint8, [4, 5, 0b11]

    assert_equal board.shift_settings(6, 7), settings1
    assert_equal board.shift_settings(4, 5, :msbfirst), settings2
    assert_equal board.shift_settings(4, 5, nil, true), settings3
    assert_equal board.shift_settings(4, 5, :msbfirst, true), settings4
  end
  
  def test_shift_write
    settings1 = board.shift_settings(4, 5)
    settings2 = board.shift_settings(4, 5, :msbfirst)
    bytes1 = pack :uint8, [1,2,3]
    bytes2 = pack :uint8, [25]
    mock = MiniTest::Mock.new
    mock.expect :call, nil, [Dino::Board::API::Message.encode(command: 21, pin: 3, value: 3, aux_message: settings1 + bytes1)]
    mock.expect :call, nil, [Dino::Board::API::Message.encode(command: 21, pin: 3, value: 1, aux_message: settings2 + bytes2)]
    
    board.stub(:write, mock) do
      board.shift_write(3, 4, 5, [1,2,3])
      board.shift_write(3, 4, 5, 25, bit_order: :msbfirst)
    end
  end

  def test_shift_read
    settings1 = board.shift_settings(4, 5)
    settings2 = board.shift_settings(4, 5, nil, true)
    settings3 = board.shift_settings(4, 5, :msbfirst, true)
    mock = MiniTest::Mock.new
    mock.expect :call, nil, [Dino::Board::API::Message.encode(command: 22, pin: 3, value: 8, aux_message: settings1)]
    mock.expect :call, nil, [Dino::Board::API::Message.encode(command: 22, pin: 3, value: 4, aux_message: settings2)]
    mock.expect :call, nil, [Dino::Board::API::Message.encode(command: 22, pin: 3, value: 4, aux_message: settings3)]
    
    board.stub(:write, mock) do
      board.shift_read(3, 4, 5, 8)
      board.shift_read(3, 4, 5, 4, preclock_high: true)
      board.shift_read(3, 4, 5, 4, bit_order: :msbfirst, preclock_high: true)
    end
  end
  
  def test_shift_listen
    settings = board.shift_settings(4, 5, :msbfirst, true)
    mock = MiniTest::Mock.new
    mock.expect :call, nil, [Dino::Board::API::Message.encode(command: 23, pin: 3, value: 4, aux_message: settings)]

    board.stub(:write, mock) do
      board.shift_listen(3, 4, 5, 4, preclock_high: true, bit_order: :msbfirst)
    end
  end

  def test_shift_stop
    mock = MiniTest::Mock.new
    mock.expect :call, nil, [Dino::Board::API::Message.encode(command: 24, pin: 3)]
    board.stub(:write, mock) do
      board.shift_stop(3)
    end
  end
end
