require 'dino'
require 'board_mock'
require 'minitest/autorun'

class BaseComponent
  include Dino::Components::Setup::Base
end

class BaseSetupTest < Minitest::Test
  def board
    @board ||= BoardMock.new
  end

  def test_requires_board
    assert_raises(ArgumentError) { BaseComponent.new }
  end

  def test_registers_with_board
    part = BaseComponent.new(board: board)
    assert_equal board.components, [part]
  end
end
