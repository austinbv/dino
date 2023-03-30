require_relative '../test_helper'

class RegisterSelectTest < Minitest::Test
  def test_includes
    assert_includes Dino::Register::ChipSelect.ancestors,
                    Dino::Behaviors::SinglePin
    assert_includes Dino::Register::ChipSelect.ancestors,
                    Dino::Behaviors::OutputPin
    assert_includes Dino::Register::ChipSelect.ancestors,
                    Dino::Behaviors::Callbacks
  end
end
