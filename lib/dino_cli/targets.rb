class DinoCLI::Generator
  TARGETS = {
    # Default target always includes all packages.
    mega: PACKAGES.each_key.map {|k| k},

    # Core is core.
    core: [:core],

    # Specific features for the old mega168 chips.
    mega168: [:core, :servo, :dht, :one_wire, :ir_out, :tone, :spi, :i2c],

    # ARM includes everytyhing except specific incompatibilities.
    arm: PACKAGES.each_key.map {|k| k} - [:serial, :tone, :ir_out, :i2c],
  }
end
