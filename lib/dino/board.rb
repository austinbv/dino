module Dino
  module Board
    autoload :Connection, "#{__dir__}/board/connection"
    autoload :API,        "#{__dir__}/board/api"
    autoload :Base,       "#{__dir__}/board/base"
    autoload :Default,    "#{__dir__}/board/default"

    def self.new(options={})
      self::Default.new(options)
    end
  end
end
