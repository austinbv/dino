require_relative '../test_helper'

class BoardMock < Dino::Board
  attr_reader :eeprom_stub
  
  def eeprom_read(start_address, length)
    # Initialize a fake EEPROM
    @eeprom_stub ||= Array.new(eeprom_length){255}
    
    # Pack it up like a string coming from the board.
    string = @eeprom_stub[start_address, length].map{ |x| x.to_s }.join(",")
    
    # Update ourselves with it.
    self.update("EE:#{start_address}-#{string}\n")
  end

  def eeprom_write(start_address, bytes)
    @eeprom_stub[start_address, bytes.length] = bytes
  end
end

class BuiltInEEPROMTest < Minitest::Test
  def board
    @board ||= BoardMock.new
  end

  def part
    @part ||= board.eeprom
  end
  
  def test_pin_ee
    assert_equal part.pin, "EE"
  end

  def test_loads_on_initialize_and_updates_correctly
    assert_equal part.state, Array.new(board.eeprom_length){255}
  end
  
  def test_delegates_to_state_array
    mock = MiniTest::Mock.new
    mock.expect(:[], 255, [0])
    mock.expect(:[]=, 128, [1, 128])
    mock.expect(:each, nil)
    mock.expect(:each_with_index, nil)
    
    part.stub(:state, mock) do
      part[0]
      part[1] = 128
      part.each { |el| el }
      part.each_with_index { |el| el }
    end
  end
  
  def test_saves_to_the_board
    part[0] = 128
    part[part.length] = 127
    part.save
    assert_equal board.eeprom_stub[0], 128
    assert_equal board.eeprom_stub[board.eeprom_length], 127
  end
end
