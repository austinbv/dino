require_relative '../../test_helper'

class APIServoTest < Minitest::Test
  include TestPacker
  
  def connection
    @connection ||= ConnectionMock.new
  end

  def board
    @board ||= Dino::Board.new(connection)
  end

  def test_on_off
    mock = MiniTest::Mock.new
    aux = pack :uint16, [544, 2400]
    mock.expect :call, nil, [Dino::Message.encode(command: 10, pin: 9, value: 1, aux_message: aux)]
    mock.expect :call, nil, [Dino::Message.encode(command: 10, pin: 9, value: 0, aux_message: aux)]

    board.stub(:write, mock) do
      board.servo_toggle(9, :on)
      board.servo_toggle(9)
    end
    mock.verify
  end

  def test_min_max
    mock = MiniTest::Mock.new
    aux = pack :uint16, [360, 2100]
    mock.expect :call, nil, [Dino::Message.encode(command: 10, pin: 9, value: 1, aux_message: aux)]

    board.stub(:write, mock) do
      board.servo_toggle(9, :on, min: 360, max: 2100)
    end
    mock.verify
  end
  
  def test_write
    mock = MiniTest::Mock.new
    mock.expect :call, nil, [Dino::Message.encode(command: 11, pin: 9, aux_message: pack(:uint16, 180))]

    board.stub(:write, mock) do
      board.servo_write(9, 180)
    end
    mock.verify
  end
end
