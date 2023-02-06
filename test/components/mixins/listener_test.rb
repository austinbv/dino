require 'test_helper'

class ListenerComponent
  include Dino::Components::Setup::Base
  include Dino::Components::Mixins::Listener

  def _listen(divider=nil); end
  def _stop_listener; end
end

class ListenerTest < Minitest::Test
  def board
    @board ||= BoardMock.new
  end

  def part
    @part ||= ListenerComponent.new(board: board, pin: 1)
  end

  def test_include_callbacks
    assert_includes ListenerComponent.ancestors,
                    Dino::Components::Mixins::Callbacks
  end

  def test_call_stop_before_listening
    mock = MiniTest::Mock.new.expect :call, nil
    part.stub(:stop, mock) { part.listen }
    mock.verify
  end

  def test_call__listen
    mock = MiniTest::Mock.new
    mock.expect :call, nil, [nil]
    mock.expect :call, nil, [32]
    part.stub(:_listen, mock) do
      part.listen
      part.listen(32)
    end
    mock.verify
  end

  def test_call__stop_listener
    mock = MiniTest::Mock.new.expect :call, nil
    part.stub(:_stop_listener, mock) { part.stop }
    mock.verify
  end

  def test_add_and_remove_callback
    callback = Proc.new{}
    part.listen(&callback)
    assert_equal [callback], part.callbacks[:listen]
    part.stop
    assert_nil part.callbacks[:listen]
  end
end
