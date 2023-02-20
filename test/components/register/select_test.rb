require 'test_helper'

class RegisterSelectTest < Minitest::Test
  def test_includes
    assert_includes Dino::Components::Register::Select.ancestors,
                    Dino::Components::Setup::SinglePin
    assert_includes Dino::Components::Register::Select.ancestors,
                    Dino::Components::Setup::Output
    assert_includes Dino::Components::Register::Select.ancestors,
                    Dino::Components::Mixins::Callbacks
  end
end
