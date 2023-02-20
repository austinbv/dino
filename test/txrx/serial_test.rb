require 'test_helper'

class DummySerial
  def read
    ""
  end

  def write(message)
    nil
  end
end

class TxRxSerialTest < Minitest::Test
  def mock_tty_device
    "/dev/mock_serial"
  end

  def txrx
    @txrx ||= Dino::TxRx::Serial.new
  end

  def io
    suppress_output do
      txrx.send(:io)
    end
  end

  def test_connect_with_device_specified
    mock = MiniTest::Mock.new.expect(:call, "serial-obj", ["/dev/ttyACM0", 9600])
    Serial.stub(:new, mock) do
      txrx = Dino::TxRx::Serial.new(device: "/dev/ttyACM0", baud: 9600)
      assert_equal "serial-obj", suppress_output { txrx.send(:io) }
    end
    mock.verify
  end

  def test_connect_with_no_devices
    txrx.stub(:tty_devices, []) do
      assert_raises(Dino::TxRx::SerialConnectError) { io }
    end
  end

  def test_connect_on_unix
    txrx.stub(:tty_devices, ['/dev/ttyACM0', '/dev/tty.usbmodem1']) do
      mock =  MiniTest::Mock.new
      # Raise error for first device
      mock.expect(:call, nil) { raise RubySerial::Error }
      mock.expect :call, "serial-obj", ['/dev/tty.usbmodem1', Dino::TxRx::Serial::BAUD]

      Serial.stub(:new, mock) do
        assert_equal "serial-obj", io
      end
      mock.verify
    end
  end

  def test_connect_on_windows
    # Simulate being on Windows
    original_platform = RUBY_PLATFORM
    Constants.redefine(:RUBY_PLATFORM, "mswin", :on => Object)

    mock =  MiniTest::Mock.new
    # Raise error for COM1
    mock.expect(:call, nil) { raise RubySerial::Error }
    mock.expect :call, "serial-obj", ["COM2", Dino::TxRx::Serial::BAUD]

    Serial.stub(:new, mock) do
      assert_equal "serial-obj", io
    end
    mock.verify

    # Set platform back to original value
    Constants.redefine(:RUBY_PLATFORM, original_platform, :on => Object)
  end

  def test_io_reset
    flush_mock = MiniTest::Mock.new.expect :call, true
    r_stop_mock = MiniTest::Mock.new.expect :call, true
    r_start_mock = MiniTest::Mock.new.expect :call, true
    w_stop_mock = MiniTest::Mock.new.expect :call, true
    w_start_mock = MiniTest::Mock.new.expect :call, true

    txrx.stub(:flush_read, flush_mock) do
      txrx.stub(:stop_read, r_stop_mock) do
        txrx.stub(:start_read, r_start_mock) do
          txrx.stub(:stop_write, w_stop_mock) do
            txrx.stub(:start_write, w_start_mock) do
              txrx.send(:io_reset)
            end
          end
        end
      end
    end
    
    flush_mock.verify
    r_stop_mock.verify
    r_start_mock.verify
    w_start_mock.verify
    w_start_mock.verify
  end

  def test_read
    txrx.stub(:_read, "02:00:00") do
      line = txrx.send(:read)
      assert_equal line, "02:00:00"
    end
  end
  
  def test_parse
    mock = MiniTest::Mock.new.expect :call, nil, ['02:00:00']
    txrx.stub(:changed, true) do
      txrx.stub(:notify_observers, mock) do
        txrx.send(:parse, '02:00:00')
      end
      mock.verify
    end
  end

  def test_stop_read
    thread = Thread.new { sleep }
    txrx.instance_variable_set(:@read_thread, thread)
    txrx.send(:stop_write)
    assert_nil txrx.instance_variable_get(:@write_thread)
  end
  
  def test_stop_write
    thread = Thread.new { sleep }
    txrx.instance_variable_set(:@write_thread, thread)
    txrx.send(:stop_write)
    assert_nil txrx.instance_variable_get(:@write_thread)
  end

  def test_write
    # Message is appended to the buffer.
    txrx.send(:stop_write)
    txrx.write('message')
    assert_equal txrx.instance_variable_get("@write_buffer"), "message"
    
    # Message is written from buffer when we start the write thread.
    mock = MiniTest::Mock.new.expect :call, nil, ['message']
    txrx.stub(:_write, mock) do
      txrx.send(:start_write)
      sleep 0.005
    end
    mock.verify
    assert_equal txrx.instance_variable_get("@write_buffer"), ""
  end

  def test_io_read_single_chars_until_newline_and_strips_it
    mock = MiniTest::Mock.new
    "line\n".split("").each do |char|
      mock.expect :read, char, [1]
    end
    txrx.stub(:io, mock) do
      assert_equal "line", txrx.send(:read)
    end
    mock.verify
  end

  def test_io_read_handles_escaped_newlines_and_backslashes
    mock = MiniTest::Mock.new
    "l1\\\nl2\\\\\n".split("").each do |char|
      mock.expect :read, char, [1]
    end
    txrx.stub(:io, mock) do
      assert_equal "l1\nl2\\", txrx.send(:read)
    end
    mock.verify
  end

  def test_io_read_returns_empty_string_if_just_newline
    mock = MiniTest::Mock.new
    mock.expect :read, "\n", [1]
    txrx.stub(:io, mock) do
      assert_equal "", txrx.send(:read)
    end
    mock.verify
  end
end
