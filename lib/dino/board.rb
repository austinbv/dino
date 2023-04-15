module Dino
  module Board
    autoload :Connection, "#{__dir__}/board/connection"
    autoload :API,        "#{__dir__}/board/api"
    autoload :Map,        "#{__dir__}/board/map"
    autoload :Base,       "#{__dir__}/board/base"

    def self.new(options={})
      self::Base.new(options)
    end
  end
end
