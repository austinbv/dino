require "minitest/autorun"
require 'simplecov'
SimpleCov.start do
  add_filter "test"
  track_files "lib/**/*.rb"
end
require 'dino'

# Nice little helper module to redefine constants quietly.
module Constants
  def self.redefine(const, value, opts={})
    opts = {:on => self.class}.merge(opts)
    opts[:on].send(:remove_const, const) if self.class.const_defined?(const)
    opts[:on].const_set(const, value)
  end
end

# Taken from: https://gist.github.com/moertel/11091573
def suppress_output
  begin
    original_stderr = $stderr.clone
    original_stdout = $stdout.clone
    $stderr.reopen(File.new('/dev/null', 'w'))
    $stdout.reopen(File.new('/dev/null', 'w'))
    retval = yield
  rescue Exception => e
    $stdout.reopen(original_stdout)
    $stderr.reopen(original_stderr)
    raise e
  ensure
    $stdout.reopen(original_stdout)
    $stderr.reopen(original_stderr)
  end
  retval
end

class TxRxMock
  def add_observer(board); true; end
  def read; true; end
  def write(str); true; end
  def handshake
    "528,1024,14,20"
  end
end

class BoardMock < Dino::Board::Default
  def initialize
    super(TxRxMock.new)
  end
end

