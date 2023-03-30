require_relative '../test_helper'

class OneWireBusTest < MiniTest::Test
  def board
    @board ||= BoardMock.new
  end
  
  def part
    @part ||= Dino::OneWire::Bus.new(board: board, pin: 1)
  end

  def inject_read(board, line, wait_for_callbacks = true)
    Thread.new do
      if wait_for_callbacks
        sleep(0.01) while board.components.empty? 
        sleep(0.01) while !board.components.first.callbacks[:read]
      end
      board.update(line)
    end
  end

  def test_read_power_supply_locks_mutex
    # Inject a response for no parasite power.
    inject_read(board, "1:0")

    mock = MiniTest::Mock.new.expect(:call, nil)
    
    part.mutex.stub(:synchronize, mock) do
      part.read_power_supply
    end
    mock.verify
  end

  def test_read_power_supply_sends_board_commands
    # Pre-initialize the bus. 
    inject_read(board, "1:0"); part
    
    board_mock = MiniTest::Mock.new
    board_mock.expect(:set_pin_mode, nil, [part.pin, :output])
    board_mock.expect(:low, 0)
    board_mock.expect(:digital_write,  nil, [part.pin, 0])
    board_mock.expect(:one_wire_reset, nil, [part.pin, 0])
    board_mock.expect(:one_wire_write, nil, [part.pin, false, [0xCC, 0xB4]])

    # Stub the parasite power response from the board.
    read_mock = MiniTest::Mock.new
    read_mock.expect(:call, 0, [1])

    part.stub(:board, board_mock) do
      part.stub(:read, read_mock) do
        part.read_power_supply
      end
    end
    board_mock.verify
    read_mock.verify
  end

  def test_device_present_in_mutex
    # Pre-initialize the bus. 
    inject_read(board, "1:0"); part

    mock = MiniTest::Mock.new.expect(:call, nil)
    
    part.mutex.stub(:synchronize, mock) do
      part.device_present
    end
    mock.verify
  end

  def test_set_device_present
    # Pre-initialize the bus. 
    inject_read(board, "1:0"); part

    mock = MiniTest::Mock.new
    mock.expect(:call, nil, [1])
    mock.expect(:call, nil, [1])
    
    part.stub(:reset, mock) do
      # Give 0 for first reading, device present
      inject_read(board, "1:0")
      assert part.device_present
      
      # Give 1 for second reading, no device
      inject_read(board, "1:1")
      refute part.device_present
    end
    mock.verify
  end

  def test_pre_callback_filter
    # Pre-initialize the bus. 
    inject_read(board, "1:0"); part

    assert_equal part.pre_callback_filter("255,180,120"), [255, 180, 120]
    assert_equal part.pre_callback_filter("127"), 127
  end

  def reset_test
    # Pre-initialize the bus. 
    inject_read(board, "1:0"); part

    mock = MiniTest::Mock.new
    mock.expect(:call, [1, true])
    mock.expect(:call, [1])
    board.stub(:one_wire_reset, mock) do
      part.reset(true)
      part.reset
    end
    mock.verify
  end
  
  def _read_test
    # Pre-initialize the bus. 
    inject_read(board, "1:0"); part

    mock = MiniTest::Mock.new.expect(:call, [1, 4])
    board.stub(:one_wire_read, mock) do
      part._read(4)
    end
    mock.verify
  end

  def write
    # Pre-initialize the bus. 
    inject_read(board, "1:0"); part

    mock = MiniTest::Mock.new
    expect(:call, [1, true, [255, 177, 0x44]])
    mock = MiniTest::Mock.new.expect(:call, [1, true, [255, 177, 0x44]])
    mock = MiniTest::Mock.new.expect(:call, [1, true, [255, 177, 0x48]])
    mock = MiniTest::Mock.new.expect(:call, [1, false, [255, 177, 0x55]])
    mock = MiniTest::Mock.new.expect(:call, [1, false, [255, 177, 0x44]])
    
    board.stub(:one_wire_write, mock) do
      # Parasite power on and parasite power functions.
      part.instance_variable_set(:@parasite_power, true)
      part.write [255, 177, 0x44]
      part.write [255, 177, 0x48]
      
      # Parasite power on and not parasite power functions.
      part.write [255, 177, 0x55]
      
      # Parasite power off and would-be parasite power function.
      part.instance_variable_set(:@parasite_power, false)
      part.write [255, 177, 0x44]
    end
    mock.verify
  end
end
