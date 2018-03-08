require 'dino'
require 'minitest/autorun'
require 'txrx_mock'
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
    stop_mock = MiniTest::Mock.new.expect :call, true
    start_mock = MiniTest::Mock.new.expect :call, true
    txrx.stub(:flush_read, flush_mock) do
      txrx.stub(:stop_read, stop_mock) do
        txrx.stub(:start_read, start_mock) do
          txrx.send(:io_reset)
        end
      end
    end
    flush_mock.verify
    stop_mock.verify
    start_mock.verify
  end

  def test_read_and_parse
    # Should not split on any colon after the first.
    txrx.stub(:read, "02:00:00") do
      txrx.stub(:changed, true) do
        mock = MiniTest::Mock.new.expect :call, nil, ['02', '00:00']
        txrx.stub(:notify_observers, mock) do
          txrx.send(:read_and_parse)
        end
        mock.verify
      end
    end
  end

  # Test start read?

  def test_stop_read
    thread = Thread.new { sleep }
    mock = MiniTest::Mock.new.expect :call, nil, [thread]
    txrx.instance_variable_set(:@thread, thread)

    Thread.stub(:kill, mock) do
      txrx.send(:stop_read)
    end
    mock.verify
  end

  def test_write
    mock = MiniTest::Mock.new.expect :write, nil, ['message']
    txrx.stub(:io, mock) do
      txrx.write('message')
    end
    mock.verify
  end

  def test_read_single_chars_until_newline_and_strips_it
    mock = MiniTest::Mock.new
    "line\n".split("").each do |char|
      mock.expect :read, char, [1]
    end
    txrx.stub(:io, mock) do
      assert_equal "line", txrx.send(:read)
    end
    mock.verify
  end

  def test_read_handles_escaped_newlines_and_backslashes
    mock = MiniTest::Mock.new
    "l1\\\nl2\\\\\n".split("").each do |char|
      mock.expect :read, char, [1]
    end
    txrx.stub(:io, mock) do
      assert_equal "l1\nl2\\", txrx.send(:read)
    end
    mock.verify
  end

  def test_read_returns_empty_string_if_just_newline
    mock = MiniTest::Mock.new
    mock.expect :read, "\n", [1]
    txrx.stub(:io, mock) do
      assert_equal "", txrx.send(:read)
    end
    mock.verify
  end
end
