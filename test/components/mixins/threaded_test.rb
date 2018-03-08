require 'dino'
require 'board_mock'
require 'minitest/autorun'

class ThreadedComponent
  include Dino::Components::Setup::Base
  include Dino::Components::Mixins::Threaded
  def foo(str="test")
    @bar = str
  end
  attr_reader :bar
  interrupt_with :foo
end

class ThreadedTest < Minitest::Test
  def board
    @board ||= BoardMock.new
  end

  def part
    @part ||= ThreadedComponent.new(board: board, pin: 1)
  end

  def test_add_interrupts_using_interrupt_with
    assert_equal ThreadedComponent.class_variable_get(:@@interrupts), [:foo]
  end

  def test_threaded_stops_threads
    mock = MiniTest::Mock.new.expect :call, nil
    part.stub(:stop_thread, mock) { part.threaded {} }
    mock.verify
  end

  def test_threaded_enables_interrupts
    mock = MiniTest::Mock.new.expect :call, nil
    part.stub(:enable_interrupts, mock) { part.threaded {} }
    mock.verify
  end

  def test_threaded_calls_block_given
    mock = MiniTest::Mock.new.expect :call, nil
    part.threaded { mock.call }
    sleep 0.1 # Should find a better way to do this.
    mock.verify
  end

  def test_thread_stored_in_instance_variable
    thread = Thread.current
    part.threaded {}
    refute_equal(thread, part.instance_variable_get(:@thread))
  end

  def test_threaded_loop_calls_block_repeatedly
    mock = MiniTest::Mock.new.expect(:call, nil).expect(:call, nil)
    part.stub(:foo, mock) do
      part.threaded_loop do
        part.foo
        sleep 0.05
      end
      sleep 0.07 # And this.
    end
    mock.verify
  end

  def test_stop_thread_kills_thread
    mock = MiniTest::Mock.new.expect(:kill, nil)
    part.instance_variable_set(:@thread, mock)
    part.stop_thread
    mock.verify
  end

  def test_interrupts_override_singleton_only
    second_part = ThreadedComponent.new(board: BoardMock.new, pin: 2)
    before_class = second_part.method(:foo)
    before_instance = part.method(:foo)

    part.enable_interrupts
    after_class = second_part.method(:foo)
    after_instance = part.method(:foo)

    assert_equal before_class, after_class
    refute_equal before_instance, after_instance
  end

  def test_original_method_called_when_interrupts_enabled
    mock = MiniTest::Mock.new.expect(:call, nil, ["dino"])
    part.stub(:foo, mock) do
      part.enable_interrupts
      part.foo("dino")
    end
    mock.verify
  end

  def test_interrupt_stops_thread
    part.enable_interrupts
    mock = MiniTest::Mock.new.expect :call, nil
    part.stub(:stop_thread, mock) { part. foo }
    mock.verify
  end
end
