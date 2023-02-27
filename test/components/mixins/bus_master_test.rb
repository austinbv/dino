require 'test_helper'

class BusMasterComponent
  include Dino::Components::Setup::Base
  include Dino::Components::Mixins::BusMaster
end

class BusMasterTest < Minitest::Test
  def board
    @board ||= BoardMock.new
  end

  def part
    @part ||= BusMasterComponent.new(board: board)
  end
  
  def test_has_mutex
    assert_equal part.mutex.class, Mutex
  end
  
  def test_components
    part.add_component "1"
    assert_equal part.components, ["1"]
    
    part.remove_component "1"
    assert_equal part.components, []
  end
end
