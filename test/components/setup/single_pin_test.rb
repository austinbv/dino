require 'test_helper'

class SinglePinComponent
  include Dino::Components::Setup::SinglePin
end

class SinglePinSetupTest < Minitest::Test
  def board
    @board ||= BoardMock.new
  end

  def part
    @part ||= SinglePinComponent.new(board: board, pin: 1)
  end

  def test_requires_pin
    assert_raises(ArgumentError) { SinglePinComponent.new(board: board) }
  end
  
  def test_mode=
    mock = Minitest::Mock.new
    mock.expect :call, nil, [1, :out] 
    board.stub(:set_pin_mode, mock) do
      part.send(:mode=, :out)
    end
  end
end
