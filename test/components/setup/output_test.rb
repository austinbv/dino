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

  def test_pin_mode
    assert_equal part.mode, :out
  end
end
