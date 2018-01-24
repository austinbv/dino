class DinoCLI::Generator
  TARGETS = {
    # Default target always includes all packages.
    mega: PACKAGES.each_key.to_a,

    # Core is core.
    core: [:core],

    # Specific features for the old mega168 chips.
    mega168: [:core, :servo, :dht, :one_wire, :ir_out, :tone, :spi, :i2c],

    # ARM includes everytyhing except specific incompatibilities.
    arm: PACKAGES.each_key.to_a - [:serial, :tone, :ir_out, :i2c],

    # A surprising amount "just works" on the ESP, notably not LCD.
    esp8266: PACKAGES.each_key.to_a - [:lcd, :serial, :ir_out, :i2c] + [:ir_out_esp8266],
  }
end
