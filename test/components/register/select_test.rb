require 'test_helper'

class RegisterSelectTest < Minitest::Test
  def board
    @board ||= BoardMock.new
  end

  def part
    @part ||= Dino::Components::Register::Select.new(board: board, pin: 14)
  end

  def test_default_to_output
    mock = MiniTest::Mock.new.expect :call, nil, [14, :out]
    board.stub(:set_pin_mode, mock) do
      part
    end
    mock.verify
  end

  def test_callbacks
    assert_includes Dino::Components::Register::Select.ancestors,
                    Dino::Components::Mixins::Callbacks
  end
end
