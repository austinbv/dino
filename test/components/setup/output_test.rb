require 'test_helper'

class OutputComponent
  include Dino::Components::Setup::Output
end

class OutputSetupTest < Minitest::Test
  def board
    @board ||= BoardMock.new
  end

  def part
    @part ||= OutputComponent.new(board: board, pin: 1)
  end

  def test_set_mode
    mock = Minitest::Mock.new
    mock.expect :call, nil, [1, :output]
    
    board.stub(:set_pin_mode, mock) do
      part
    end
    mock.verify
    
    assert_equal :output, part.mode
  end
end
