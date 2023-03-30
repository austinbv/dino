module Dino
  module Display
    autoload :HD44780, "#{__dir__}/display/hd44780"
    autoload :SSD1306, "#{__dir__}/display/ssd1306"
  end
end
