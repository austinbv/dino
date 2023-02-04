require 'dino'
require 'txrx_mock'
require 'minitest/autorun'

class APICoreTest < Minitest::Test
  def txrx
    @txrx ||= TxRxMock.new
  end

  def board
    @board ||= Dino::Board.new(txrx)
  end

  def test_set_pin_mode
    mock = MiniTest::Mock.new
    mock.expect(:call, nil, [Dino::Message.encode(command: 0, pin: 1, value: board.low)])
    mock.expect(:call, nil, [Dino::Message.encode(command: 0, pin: 1, value: board.high)])

    board.stub(:write, mock) do
      board.set_pin_mode 1, :out
      board.set_pin_mode 1, :in
    end
    mock.verify
  end

  def test_set_pullup
    mock = MiniTest::Mock.new
    mock.expect(:call, nil, [Dino::Message.encode(command: 1, pin: 1, value: board.low)])
    mock.expect(:call, nil, [Dino::Message.encode(command: 1, pin: 1, value: board.high)])

    board.stub(:write, mock) do
      board.set_pullup 1, false
      board.set_pullup 1, true
    end
    mock.verify
  end

  def test_digital_write
    mock = MiniTest::Mock.new
    mock.expect(:call, nil, [Dino::Message.encode(command: 1, pin: 1, value: board.low)])
    mock.expect(:call, nil, [Dino::Message.encode(command: 1, pin: 1, value: board.high)])

    board.stub(:write, mock) do
      board.digital_write 1, board.low
      board.digital_write 1, board.high
    end
    mock.verify
  end

  def test_digital_read
    mock = MiniTest::Mock.new
    mock.expect(:call, nil, [Dino::Message.encode(command: 2, pin: 1)])

    board.stub(:write, mock) do
      board.digital_read 1
    end
    mock.verify
  end

  def test_analog_write
    mock = MiniTest::Mock.new
    mock.expect(:call, nil, [Dino::Message.encode(command: 3, pin: 1, value: board.low)])
    mock.expect(:call, nil, [Dino::Message.encode(command: 3, pin: 1, value: board.analog_high)])
    mock.expect(:call, nil, [Dino::Message.encode(command: 3, pin: 1, value: 128)])

    board.stub(:write, mock) do
      board.analog_write 1, board.low
      board.analog_write 1, board.analog_high
      board.analog_write 1, 128
    end
    mock.verify
  end

  def test_analog_read
    mock = MiniTest::Mock.new
    mock.expect(:call, nil, [Dino::Message.encode(command: 4, pin: 1)])

    board.stub(:write, mock) do
      board.analog_read 1
    end
    mock.verify
  end

  def test_set_listener
    mock = MiniTest::Mock.new

    # \x00\x04 corresponds to the default divider of 16 (2^4)
    mock.expect(:call, nil, [Dino::Message.encode(command: 5, pin: 1, value: 0, aux_message: "\x00\x04")])
    mock.expect(:call, nil, [Dino::Message.encode(command: 5, pin: 1, value: 0, aux_message: "\x01\x04")])
    mock.expect(:call, nil, [Dino::Message.encode(command: 5, pin: 1, value: 1, aux_message: "\x01\x04")])
    mock.expect(:call, nil, [Dino::Message.encode(command: 5, pin: 1, value: 1, aux_message: "\x01\x00")])

    board.stub(:write, mock) do
      board.set_listener(1, :off)
      board.set_listener(1, :off, mode: :analog)
      board.set_listener(1, :on, mode: :analog)
      board.set_listener(1, :on, mode: :analog, divider: 1)
    end
    mock.verify
  end

  def test_digital_listen
    mock = MiniTest::Mock.new
    mock.expect(:call, nil, [1, :on], mode: :digital, divider: 4)

    board.stub(:set_listener, mock) do
      board.digital_listen(1)
    end
  end

  def test_analog_listen
    mock = MiniTest::Mock.new
    mock.expect(:call, nil, [1, :on], mode: :analog, divider: 16)

    board.stub(:set_listener, mock) do
      board.analog_listen(1)
    end
  end

  def test_stop_listener
    mock = MiniTest::Mock.new
    mock.expect(:call, nil, [1, :off])

    board.stub(:set_listener, mock) do
      board.stop_listener(1)
    end
  end

  def test_analog_resolution
    mock = MiniTest::Mock.new
    mock.expect(:call, nil, [Dino::Message.encode(command: 96, value: 10)])

    board.stub(:write, mock) do
      board.analog_resolution = 10
    end
    mock.verify
  end
end
