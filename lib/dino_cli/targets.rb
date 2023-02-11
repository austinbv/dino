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
    arm: STANDARD_PACKAGES - [:serial, :tone, :ir_out],

    # A surprising amount "just works" on the ESP, notably not LCD.
    esp8266: STANDARD_PACKAGES - [:lcd, :serial, :ir_out] + [:ir_out_esp8266],
  }
end
