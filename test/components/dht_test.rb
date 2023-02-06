require 'dino'
require 'board_mock'
require 'minitest/autorun'

class DHTTest < MiniTest::Test
  PIN = 1
  
  # Actual raw data from a sensor
  GOOD_STRING  = "14,82,77,57,26,52,26,57,26,51,32,51,26,57,26,52,72,57,26,67,72,57,26,51,27,56,72,52,77,52,77,51,26,57,72,67,26,52,26,57,26,52,26,57,26,51,31,52,26,57,72,67,26,52,26,56,72,57,26,52,26,57,72,52,77,51,72,67,72,57,72,51,32,51,26,57,26,52,72,57,72,56,72,47"
  GOOD_ARRAY   = [14, 82, 77, 57, 26, 52, 26, 57, 26, 51, 32, 51, 26, 57, 26, 52, 72, 57, 26, 67, 72, 57, 26, 51, 27, 56, 72, 52, 77, 52, 77, 51, 26, 57, 72, 67, 26, 52, 26, 57, 26, 52, 26, 57, 26, 51, 31, 52, 26, 57, 72, 67, 26, 52, 26, 56, 72, 57, 26, 52, 26, 57, 72, 52, 77, 51, 72, 67, 72, 57, 72, 51, 32, 51, 26, 57, 26, 52, 72, 57, 72, 56, 72, 47]
  SHORT_ARRAY  = [1,2,3,4,5,6]
  
  # Make test data with a bad CRC byte (all 1s = 255).
  def bad_crc
    bad_crc = GOOD_ARRAY.dup
    (67..82).each { |i| bad_crc[i] = 56 }
    bad_crc
  end
  
  def board
    @board ||= BoardMock.new
  end

  def part
    @part ||= Dino::Components::DHT.new(board: board, pin:PIN)
  end
  
  # It should tell the board to do a #pulse_read
  def test__read
    part
    mock = MiniTest::Mock.new.expect(:call, nil, [PIN], reset: board.low, reset_time: 1000, pulse_limit: 84)
    board.stub(:pulse_read, mock) do
      part._read
    end
    mock.verify
  end
  
  # Callback pre filter should convert string of bytes to array and call #decode with it.
  def test_pre_callback_filter
    part
    mock = MiniTest::Mock.new.expect(:call, nil, [GOOD_ARRAY])
    part.stub(:decode, mock) do
      part.update(GOOD_STRING)
    end
  end
  
  def test_decode
    # Error message in output if data is missing.
    result = part.decode(SHORT_ARRAY)
    assert result.keys.include? :error
    assert result[:error].match(/missing/i)
    
    # Error message in output if bad CRC.
    result = part.decode(bad_crc)
    assert result.keys.include? :error
    assert result[:error].match(/crc/i)
    
    # It should calculate output correctly.
    result = part.decode(GOOD_ARRAY)
    assert_equal result, {celsius: 29.5, farenheit: 85.1, humidity: 66.9}
  end
  
  def test_crc
    refute part.crc(bad_crc)
  end
end
