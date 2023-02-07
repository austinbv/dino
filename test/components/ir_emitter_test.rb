require 'test_helper'

class IREmitterTest < MiniTest::Test
  def board
    @board ||= BoardMock.new
  end

  def part
    @part ||= Dino::Components::IREmitter.new(board: board, pin:1)
  end
  
  def test_pulse_count_validation
    assert_raises(ArgumentError) do
      part.emit Array.new(257) { 0 }
    end
  end
  
  def test_numeric_validation
    assert_raises(ArgumentError) do
      part.emit ["a", "b", "c"]
    end
  end
  
  def test_pulse_length_validation
    assert_raises(ArgumentError) do
      part.emit [65536]
    end
  end
  
  def test_emits
    part
    mock = MiniTest::Mock.new.expect(:call, nil, [1, 38, [127,0]])
    board.stub(:infrared_emit, mock) do
      part.emit([127,0])
    end
    mock.verify
  end
end
