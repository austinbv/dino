require_relative '../../test_helper'

class MessageTest < Minitest::Test
  def test_require_a_command
    assert_raises(ArgumentError) { Dino::Message.encode }
    assert_instance_of String, Dino::Message.encode(command: 90)
  end

  def test_require_command_in_correct_range
    assert_raises(ArgumentError) { Dino::Message.encode command: -1 }
    assert_raises(ArgumentError) { Dino::Message.encode command: 256 }
    assert_raises(ArgumentError) { Dino::Message.encode command: 42.2 }
  end

  def test_require_pin_in_correct_range
    assert_raises(ArgumentError) { Dino::Message.encode command: 0, pin: -1 }
    assert_raises(ArgumentError) { Dino::Message.encode command: 0, pin: 256 }
    assert_raises(ArgumentError) { Dino::Message.encode command: 0, pin: 42.2 }
  end

  def test_require_value_in_correct_range
    assert_raises(ArgumentError) { Dino::Message.encode command: 0, value: -1 }
    assert_raises(ArgumentError) { Dino::Message.encode command: 0, value: 10000 }
    assert_raises(ArgumentError) { Dino::Message.encode command: 0, value: 42.2 }
  end

  def test_validates_aux_message_length
    too_big_message = Array.new(529) { "a" }.join 
    assert_raises(ArgumentError) { Dino::Message.encode command: 0, value: 0, aux_message: too_big_message }
  end

  def test_build_messages_correctly
    assert_equal "1.1.1\n",    Dino::Message.encode(command: 1, pin: 1, value: 1)
    assert_equal "1.1\n",      Dino::Message.encode(command: 1, pin: 1)
    assert_equal "1..1\n",     Dino::Message.encode(command: 1, value: 1)
    assert_equal "1\n",        Dino::Message.encode(command: 1)
    assert_equal "1...test\n", Dino::Message.encode(command: 1, aux_message: "test")
  end

  def test_escape_newline_in_aux
    assert_equal  "1...line1\\\nline2\\\n\n",
                  Dino::Message.encode(command: 1, aux_message: "line1\nline2\n")
  end

  def test_escape_backslash_in_aux
    assert_equal  "1...line1\\\\line2\\\\\n",
                  Dino::Message.encode(command: 1, aux_message: "line1\\line2\\")
  end

  def test_escape_newline_and_backslashes_together
    assert_equal  "1...line1\\\\\\\nline2\\\\\\\n\n",
                  Dino::Message.encode(command: 1, aux_message: "line1\\\nline2\\\n")
  end
end
