require 'dino'
require 'board_mock'
require 'minitest/autorun'

class IREmitterTest < MiniTest::Test
  def board
    @board ||= BoardMock.new
  end

  def part
    @part ||= Dino::Components::IREmitter.new(board: board, pin:1)
  end

  # These are really API tests.
  # Should move these and test that API methods get called here instead.
  def test_packs_pulses_correctly
    part
    string = "16.1.38.#{[4].pack('C')}#{[100,200,300,400].pack('S<*')}\n"
    mock = MiniTest::Mock.new.expect(:call, nil, [string])
    board.stub(:write, mock) { part.send [100,200,300,400] }
  end

  def test_accepts_modulation_frequency_as_option
    part
    string = "16.1.40.#{[4].pack('C')}#{[100,200,300,400].pack('S<*')}\n"
    mock = MiniTest::Mock.new.expect(:call, nil, [string])
    board.stub(:write, mock) { part.send [100,200,300,400], frequency: 40 }
  end
end
