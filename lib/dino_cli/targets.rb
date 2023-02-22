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

    # ARM includes everytyhing except specific incompatibilities.
    sam3x: STANDARD_PACKAGES - [:serial, :tone, :ir_out],

    # ESP8266 mostly working.
    esp8266: STANDARD_PACKAGES - [:lcd, :serial, :ir_out] + [:ir_out_esp8266],
    
    # ESP is missing LCD, IR, and Software Serial
    esp32: [:core, :tone, :one_wire, :servo, :shift, :spi, :i2c]
  }
end
