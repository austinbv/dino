require_relative '../test_helper'

class BusControllerComponenet
  include Dino::Behaviors::Component
  include Dino::Behaviors::BusController
end

class BusControllerTest < Minitest::Test
  def board
    @board ||= BoardMock.new
  end

  def part
    @part ||= BusControllerComponenet.new(board: board)
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