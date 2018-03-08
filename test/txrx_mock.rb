require 'dino'

class TxRxMock
  def add_observer(board); true; end
  def read; true; end
  def write(str); true; end
  def handshake
    "528,14,20"
  end
end
