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

  def test_mode_and_pullup
    mock = Minitest::Mock.new
    mock.expect :call, nil, [1, :input]
    mock.expect :call, nil, [1, :input_pulldown]
    mock.expect :call, nil, [1, :input_pullup]
    mock.expect :call, nil, [1, :input_output]
    
    board.stub(:set_pin_mode, mock) do
      part
      InputComponent.new(board: board, pin: 1, pulldown: true)
      InputComponent.new(board: board, pin: 1, pullup: true)
      InputComponent.new(board: board, pin: 1, mode: :input_output)
    end
    mock.verify
    
    assert_equal :input, part.mode
  end

  def test_stop_listener
    mock = Minitest::Mock.new
    mock.expect :call, nil, [1]
    board.stub(:stop_listener, mock) do
      part._stop_listener
    end
    mock.verify
  end
end
