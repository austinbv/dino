require 'test_helper'

class SinglePinComponent
  include Dino::Components::Setup::Input
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
end
