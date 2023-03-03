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
    mega168: [:core, :servo, :shift, :tone, :spi, :i2c],

    # SAM3X includes everytyhing except specific incompatibilities.
    sam3x: STANDARD_PACKAGES - [:serial, :tone, :ir_out],
    
    # SAMD includes everytyhing except specific incompatibilities.
    samd: STANDARD_PACKAGES - [:serial],

    # ESP8266 mostly working.
    esp8266: STANDARD_PACKAGES - [:lcd, :serial, :ir_out] + [:ir_out_esp],
    
    # ESP32 mostly working.
    esp32: STANDARD_PACKAGES - [:lcd, :serial, :ir_out] + [:ir_out_esp],
  }
end
