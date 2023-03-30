require_relative '../../test_helper'

class APIEEPROMTest < Minitest::Test
  include Dino::Board::API::Helper
  
  def connection
    @connection ||= ConnectionMock.new
  end

  def board
    @board ||= Dino::Board.new(connection)
  end

  def test_eeprom_read
    mock = MiniTest::Mock.new
    mock.expect :call, nil, [(Dino::Board::API::Message.encode command: 7, value: 16, aux_message: pack(:uint16, 15))]

    board.stub(:write, mock) do
      board.eeprom_read(15, 16)
    end
    mock.verify
  end

  def test_eeprom_write
    data = (1..16).to_a
    mock = MiniTest::Mock.new
    mock.expect :call, nil, [(Dino::Board::API::Message.encode command: 8, value: data.length, aux_message: pack(:uint16, 15) + pack(:uint8, data))]

    board.stub(:write, mock) do
      board.eeprom_write(15, data)
    end
    mock.verify
  end
end
