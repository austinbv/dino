require_relative '../test_helper'

class BoardPulseTest < Minitest::Test
  include TestPacker

  def connection
    @connection ||= ConnectionMock.new
  end

  def board
    @board ||= Dino::Board.new(connection)
  end

  def test_pulse_read
    # Default settings
    mock = MiniTest::Mock.new
    aux = pack(:uint16, [0, 200]) << pack(:uint8, 100)
    message = Dino::Message.encode command: 9, pin: 4, value: 0b00, aux_message: aux
    
    mock.expect :call, nil, [message]
    board.stub(:write, mock) do
      board.pulse_read(4)
    end
    mock.verify
    
    # Good options
    mock = MiniTest::Mock.new
    aux = pack(:uint16, [1000, 200]) << pack(:uint8, 160)
    message1 = Dino::Message.encode command: 9, pin: 4, value: 0b01, aux_message: aux
    message2 = Dino::Message.encode command: 9, pin: 4, value: 0b11, aux_message: aux
    
    mock.expect :call, nil, [message1]
    mock.expect :call, nil, [message2]
    board.stub(:write, mock) do
      board.pulse_read(4, reset: board.low, reset_time: 1000, timeout: 200, pulse_limit: 160)
      board.pulse_read(4, reset: board.high, reset_time: 1000, timeout: 200, pulse_limit: 160)
    end
    mock.verify
    
    # Bad options
    assert_raises(ArgumentError) { board.pulse_read(4, reset_time: 65536)  }
    assert_raises(ArgumentError) { board.pulse_read(4, reset_time: -1)     }
    assert_raises(ArgumentError) { board.pulse_read(4, reset_time: "bad")  }
    assert_raises(ArgumentError) { board.pulse_read(4, timeout: 65536)     }
    assert_raises(ArgumentError) { board.pulse_read(4, timeout: -1)        }
    assert_raises(ArgumentError) { board.pulse_read(4, timeout: "bad")     }
    assert_raises(ArgumentError) { board.pulse_read(4, pulse_limit: 256)   }
    assert_raises(ArgumentError) { board.pulse_read(4, pulse_limit: -1)    }    
    assert_raises(ArgumentError) { board.pulse_read(4, pulse_limit: "bad") }
  end
end