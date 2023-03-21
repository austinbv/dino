require 'test_helper'

class APICoreTest < Minitest::Test
  include Dino::API::Helper
  
  def txrx
    @txrx ||= TxRxMock.new
  end

  def board
    @board ||= Dino::Board.new(txrx)
  end

  def test_set_pin_mode
    mock = MiniTest::Mock.new
    mock.expect(:call, nil, [Dino::Message.encode(command: 0, pin: 1, value: 0b000)])
    mock.expect(:call, nil, [Dino::Message.encode(command: 0, pin: 1, value: 0b010)])
    mock.expect(:call, nil, [Dino::Message.encode(command: 0, pin: 1, value: 0b100)])
    mock.expect(:call, nil, [Dino::Message.encode(command: 0, pin: 1, value: 0b001)])
    mock.expect(:call, nil, [Dino::Message.encode(command: 0, pin: 1, value: 0b011)])
    mock.expect(:call, nil, [Dino::Message.encode(command: 0, pin: 1, value: 0b101)])
    mock.expect(:call, nil, [Dino::Message.encode(command: 0, pin: 1, value: 0b111)])  

    board.stub(:write, mock) do
      board.set_pin_mode 1, :output
      board.set_pin_mode 1, :output_pwm
      board.set_pin_mode 1, :output_dac
      board.set_pin_mode 1, :input
      board.set_pin_mode 1, :input_pulldown
      board.set_pin_mode 1, :input_pullup
      board.set_pin_mode 1, :input_output
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

  def test_pwm_write
    mock = MiniTest::Mock.new
    mock.expect(:call, nil, [Dino::Message.encode(command: 3, pin: 1, value: board.low)])
    mock.expect(:call, nil, [Dino::Message.encode(command: 3, pin: 1, value: board.analog_high)])
    mock.expect(:call, nil, [Dino::Message.encode(command: 3, pin: 1, value: 128)])

    board.stub(:write, mock) do
      board.pwm_write 1, board.low
      board.pwm_write 1, board.analog_high
      board.pwm_write 1, 128
    end
    mock.verify
  end
  
  def test_dac_write
    mock = MiniTest::Mock.new
    mock.expect(:call, nil, [Dino::Message.encode(command: 4, pin: 1, value: board.low)])
    mock.expect(:call, nil, [Dino::Message.encode(command: 4, pin: 1, value: board.analog_high)])
    mock.expect(:call, nil, [Dino::Message.encode(command: 4, pin: 1, value: 128)])

    board.stub(:write, mock) do
      board.dac_write 1, board.low
      board.dac_write 1, board.analog_high
      board.dac_write 1, 128
    end
    mock.verify
  end

  def test_analog_read
    mock = MiniTest::Mock.new
    mock.expect(:call, nil, [Dino::Message.encode(command: 5, pin: 1)])

    board.stub(:write, mock) do
      board.analog_read 1
    end
    mock.verify
  end

  def test_set_listener
    mock = MiniTest::Mock.new

    # \x00\x04 corresponds to the default divider of 16 (2^4)
    mock.expect(:call, nil, [Dino::Message.encode(command: 6, pin: 1, value: 0, aux_message: "\x00\x04")])
    mock.expect(:call, nil, [Dino::Message.encode(command: 6, pin: 1, value: 0, aux_message: "\x01\x04")])
    mock.expect(:call, nil, [Dino::Message.encode(command: 6, pin: 1, value: 1, aux_message: "\x01\x04")])
    mock.expect(:call, nil, [Dino::Message.encode(command: 6, pin: 1, value: 1, aux_message: "\x01\x00")])

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
  
  def test_pulse_read
    # Default settings
    mock = MiniTest::Mock.new
    aux = pack(:uint16, [0, 200]) << pack(:uint8, 100)
    message = Dino::Message.encode command: 9, pin: 4, value: 0b00, aux_message: aux
    
    mock.expect :call, nil, [message]
    board.stub(:write, mock) do
      board.pulse_read(4)
    end
    mock.verify
    
    # Good options
    mock = MiniTest::Mock.new
    aux = pack(:uint16, [1000, 200]) << pack(:uint8, 160)
    message1 = Dino::Message.encode command: 9, pin: 4, value: 0b01, aux_message: aux
    message2 = Dino::Message.encode command: 9, pin: 4, value: 0b11, aux_message: aux
    
    mock.expect :call, nil, [message1]
    mock.expect :call, nil, [message2]
    board.stub(:write, mock) do
      board.pulse_read(4, reset: board.low, reset_time: 1000, timeout: 200, pulse_limit: 160)
      board.pulse_read(4, reset: board.high, reset_time: 1000, timeout: 200, pulse_limit: 160)
    end
    mock.verify
    
    # Bad options
    assert_raises(ArgumentError) { board.pulse_read(4, reset_time: 65536) }
    assert_raises(ArgumentError) { board.pulse_read(4, reset_time: -1) }
    assert_raises(ArgumentError) { board.pulse_read(4, timeout: 65536) }
    assert_raises(ArgumentError) { board.pulse_read(4, timeout: -1) }
    assert_raises(ArgumentError) { board.pulse_read(4, pulse_limit: 256) }
    assert_raises(ArgumentError) { board.pulse_read(4, pulse_limit: -1) }    
  end
  
  def micro_delay   
    aux = pack(:uint16, [1000])
    message = Dino::Message.encode command: 99, aux_message: aux
    mock = MiniTest::Mock.new.expect :call, nil, [message]
    
    board.stub(:write, mock) do
      board.micro_delay(1000)
    end
    
    assert_raises(ArgumentError) { board.micro_delay(65536) }  
  end
end
