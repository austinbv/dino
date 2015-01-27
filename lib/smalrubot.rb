require 'smalrubot/board_not_found'
require 'smalrubot/version'
require 'smalrubot/tx_rx'
require 'smalrubot/board'
require 'smalrubot/board/studuino'
require 'smalrubot/components'

module Smalrubot
  @@debug = false

  module_function

  def debug_log(*message)
    if debug?
      puts(sprintf(*message).chomp)
    end
  end

  def show_backtrace(exception)
    if debug?
      puts(exception)
      puts('    ' + exception.backtrace.join("\n    "))
    end
  end

  def debug?
    @@debug
  end

  def debug_mode=(val)
    @@debug = val
  end
end
