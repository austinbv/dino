require 'dino'
require 'board_mock'
require 'minitest/autorun'

class LedTest < MiniTest::Test
  def board
    @board ||= BoardMock.new
  end

  def part
    @part ||= Dino::Components::Led.new(board: board, pin:1)
  end

  def test_blink_runs_in_thread
    mock = MiniTest::Mock.new.expect :call, nil
    part.stub(:threaded_loop, mock) do
      part.blink(0.5)
    end
    mock.verify
  end
end
