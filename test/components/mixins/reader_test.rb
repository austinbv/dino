require 'test_helper'

class ReaderComponent
  include Dino::Components::Setup::Base
  include Dino::Components::Mixins::Reader
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
  end

  def test_include_callbacks
    assert_includes ReaderComponent.ancestors,
                    Dino::Components::Mixins::Callbacks
  end

  def test_read_once
    mock = MiniTest::Mock.new.expect :call, nil
    inject(1)
    part.stub(:_read, mock) { part.read }
    mock.verify
  end

  # test returns read value
  # test blocks main thread
  # test read_using -> {}

  def test_add_run_remove_callback
    cb = MiniTest::Mock.new.expect :call, nil
    inject(1)
    part.read { cb.call }
    assert_nil part.callbacks[:read]
    cb.verify
  end
end
