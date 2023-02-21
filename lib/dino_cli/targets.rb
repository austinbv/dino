class DinoCLI::Generator
  STANDARD_PACKAGES = PACKAGES.each_key.map do |package|
                        package unless PACKAGES[package][:only]
                      end.compact

  TARGETS = {
    # Default target includes all standard package.
    mega: STANDARD_PACKAGES,

    # Core is core.
    core: [:core],

    # Specific features for the old mega168 chips.
    mega168: [:core, :servo, :shift,:tone, :spi, :i2c],

    # ARM includes everytyhing except specific incompatibilities.
    sam3x: STANDARD_PACKAGES - [:serial, :tone, :ir_out],

    # ESP8266 mostly working.
    esp8266: STANDARD_PACKAGES - [:lcd, :serial, :ir_out] + [:ir_out_esp8266],
    
    # Just core implementation on the ESP32 for now.
    esp32: [:core, :shift, :spi]
  }
end
