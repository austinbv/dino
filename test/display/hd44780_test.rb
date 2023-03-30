require_relative '../test_helper'

class HD44780Test < MiniTest::Test
  def board
    @board ||= BoardMock.new
  end

  def part
    @part ||= Dino::Display::HD44780.new cols: 16, rows: 2,
                                            board: board,
                                            pins: { rs: 8, enable: 9,
                                                    d4: 4, d5: 5, d6: 6, d7: 7 }
  end
  
  def test_pin_validation
    # Only given one pin out of d0-d3.
    assert_raises do
      Dino::Display::HD44780.new board: board, pins: { rs: 12, enable: 11,
                                                      d4: 5, d5: 4, d6: 3, d7: 2, d3: 1 }
    
    end 
  end
end
