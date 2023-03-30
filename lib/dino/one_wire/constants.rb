module Dino
  module OneWire
    module Constants
      READ_POWER_SUPPLY = 0xB4
      CONVERT_T         = 0x44
      SEARCH_ROM        = 0xF0
      READ_ROM          = 0x33
      SKIP_ROM          = 0xCC
      MATCH_ROM         = 0x55
      ALARM_SEARCH      = 0xEC
      READ_SCRATCH      = 0xBE
      WRITE_SCRATCH     = 0x4E
      COPY_SCRATCH      = 0x48
      RECALL_EEPROM     = 0xB8
    end
  end
end
