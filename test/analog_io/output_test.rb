require_relative '../test_helper'

class AnalogIOOutputTest < Minitest::Test
  def board
    @board ||= BoardMock.new
  end

  def part
    @part ||= Dino::AnalogIO::Output.new(board: board, pin: 14)
  end
  
  def test_mode_set
    assert_equal :output_dac, part.mode
  end
  
  def test_dac_write
    mock = MiniTest::Mock.new.expect :call, nil, [14, 128]

    board.stub(:dac_write, mock) do
      part.write 128
    end
    mock.verify
    
    assert_equal 128, part.state
  end
end
