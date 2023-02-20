require 'test_helper'

class LCDTest < MiniTest::Test
  def board
    @board ||= BoardMock.new
  end

  def part
    @part ||= Dino::Components::LCD.new cols: 16, rows: 2,
                                        board: board,
                                        pins: { rs: 12, enable: 11,
                                                d4: 5, d5: 4, d6: 3, d7: 2 }
  end

  def test_initialize
    mock = MiniTest::Mock.new
    mock.expect :call, nil, ["10..0.12,11,5,4,3,2\n"]
    mock.expect :call, nil, ["10..1.16,2\n"]
    board.stub(:write, mock) do
      part
    end
    mock.verify
  end

  Dino::Components::LCD::LIBRARY_COMMANDS.each_pair do |command, command_id|
    define_method("test_#{command.to_s}".to_sym) do
      part
      mock = MiniTest::Mock.new.expect :call, nil, [Dino::Message.encode(command: 10, value: command_id)]
      board.stub(:write, mock) { part.send(command) }
      mock.verify
    end
  end

  def test_set_cursor
    part
    mock = MiniTest::Mock.new.expect :call, nil, [Dino::Message.encode(command: 10, value: 4, aux_message: "0,1")]
    board.stub(:write, mock) { part.set_cursor(0,1) }
    mock.verify
  end

  def test_puts
    part
    mock = MiniTest::Mock.new.expect :call, nil, [Dino::Message.encode(command: 10, value: 5, aux_message: "AB")]
    board.stub(:write, mock) { part.puts("AB")}
    mock.verify
  end
end
