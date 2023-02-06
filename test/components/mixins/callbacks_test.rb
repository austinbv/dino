require 'test_helper'

class CallbackComponent
  include Dino::Components::Setup::Base
  include Dino::Components::Mixins::Callbacks

  def pre_callback_filter(data)
    "dino: #{data}"
  end
end

class CallbacksTest < Minitest::Test
  def board
    @board ||= BoardMock.new
  end

  def part
    @part ||= CallbackComponent.new(board: board, pin: 1)
  end

  def test_add_callback
    callback = Proc.new{}
    part.add_callback(&callback)
    assert_equal part.callbacks, {persistent: [callback]}
  end

  def test_add_callback_with_key
    callback = Proc.new{}
    part.add_callback(:key, &callback)
    assert_equal({key: [callback]}, part.callbacks)
  end

  def add_two_callbacks
    @callback1 = Proc.new{}
    @callback2 = Proc.new{}
    part.add_callback(&@callback1)
    part.add_callback(:read, &@callback2)
  end

  def test_remove_callback
    add_two_callbacks
    part.remove_callbacks
    assert_equal({}, part.callbacks)
  end

  def test_remove_callback_with_key
    add_two_callbacks
    part.remove_callbacks(:read)
    assert_nil part.callbacks[:read]
    assert_equal [@callback1], part.callbacks[:persistent]
  end

  def test_update_runs_callbacks_and_removes_read_callbacks
    cb1 = MiniTest::Mock.new.expect :call, nil
    cb2 = MiniTest::Mock.new.expect :call, nil
    part.add_callback        { cb1.call }
    part.add_callback(:read) { cb2.call }
    part.update("data")
    assert_nil part.callbacks[:read]
    cb1.verify
    cb2.verify
  end

  def test_pre_callback_filter_modifies_data
    cb = MiniTest::Mock.new.expect :call, nil, ["dino: value"]
    part.add_callback { |x| cb.call(x) }
    part.update("value")
    cb.verify
  end

  def test_update_self
    part.update("test")
    assert_equal "dino: test", part.state
  end
end
