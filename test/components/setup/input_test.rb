require 'test_helper'

class InputComponent
  include Dino::Components::Setup::Input
end

class InputSetupTest < Minitest::Test
  def board
    @board ||= BoardMock.new
  end

  def part
    @part ||= InputComponent.new(board: board, pin: 1)
  end

  def test_pin_mode
    mock = Minitest::Mock.new.expect :call, nil, [1, :in]
    board.stub(:set_pin_mode, mock) do
      part
    end
    mock.verify
  end

  def test_pullup
    mock = Minitest::Mock.new
    mock.expect :call, nil, [1, nil]
    mock.expect :call, nil, [1, true]
    board.stub(:set_pullup, mock) do
      part.pullup = true
    end
    mock.verify
  end

  def test_pullup_in_options
    mock = Minitest::Mock.new.expect :call, nil, [2, true]
    board.stub(:set_pullup, mock) do
      InputComponent.new(board: board, pin: 2, pullup: true)
    end
  end
end
