module Dino
  module Register
    autoload :ChipSelect,   "#{__dir__}/register/chip_select"
    autoload :Input,        "#{__dir__}/register/input"
    autoload :Output,       "#{__dir__}/register/output"
    autoload :ShiftInput,   "#{__dir__}/register/shift_input"
    autoload :ShiftOutput,  "#{__dir__}/register/shift_output"
    autoload :SPIInput,     "#{__dir__}/register/spi_input"
    autoload :SPIOutput,    "#{__dir__}/register/spi_output"
  end
end
