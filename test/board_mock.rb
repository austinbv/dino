require 'dino'
require 'txrx_mock'

class BoardMock < Dino::Board::Default
  def initialize
    super(TxRxMock.new)
  end
end
