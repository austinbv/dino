require 'rspec'

require File.expand_path(File.join('../..', 'lib/dino'), __FILE__)

# Nice little helper module to redefine constants quietly.
module Constants
  def self.redefine(const, value, opts={})
    opts = {:on => self.class}.merge(opts)
    opts[:on].send(:remove_const, const) if self.class.const_defined?(const)
    opts[:on].const_set(const, value)
  end
end

module BoardMock
  def self.included(base)
    base.class_eval do 
      let(:txrx)  { mock(:txrx, add_observer: true, handshake: 14, write: true, read: true) }
      let(:board) { Dino::Board.new(txrx) }
    end
  end
end
