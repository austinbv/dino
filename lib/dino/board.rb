module Dino
  module Board
    require 'dino/board/base'
    require 'dino/board/default'
    require 'dino/board/esp8266'

    def self.new(options={})
      self::Default.new(options)
    end
  end
end
