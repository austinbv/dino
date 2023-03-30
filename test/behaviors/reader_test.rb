require_relative '../test_helper'

class ReaderComponent
  include Dino::Behaviors::Component
  include Dino::Behaviors::Reader
  def _read; end
end

class ReaderTest < Minitest::Test
  def board
    @board ||= BoardMock.new
  end

  def part
    @part ||= ReaderComponent.new(board: board, pin: 1)
  end

  def inject(data, wait_for_callbacks = true)
    Thread.new do
      if wait_for_callbacks
        while (!part.callbacks[:read]) do; sleep 0.01; end
      end
      loop do
        sleep 0.01
        part.update(data)
        break unless part.callbacks[:read]
      end
    end

    # Give the thread some to get into its loop.
    sleep 0.05
  end

  def test_include_callbacks
    assert_includes ReaderComponent.ancestors,
                    Dino::Behaviors::Callbacks
  end

  def test_read_once
    mock = MiniTest::Mock.new.expect :call, nil
    inject(1)
    
    part.stub(:_read, mock) do
      part.read
    end
    mock.verify
  end

  def test_return_value
    inject(42)
    assert_equal part.read, 42
  end
  
  def test_read_using
    inject(1)
    reader = MiniTest::Mock.new.expect :call, nil
    part.read_using -> { reader.call }
    reader.verify
  end

  def test_add_run_remove_callback
    cb = MiniTest::Mock.new.expect :call, nil
    inject(1)
    part.read { cb.call }
    assert_nil part.callbacks[:read]
    cb.verify
  end
end
