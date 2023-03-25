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
    mega168: [:core, :one_wire, :tone, :shift, :i2c, :spi, :servo],

    # SAM3X includes everytyhing except specific incompatibilities.
    sam3x: STANDARD_PACKAGES - [:tone, :serial, :ir_out],
    
    # SAMD includes everytyhing except specific incompatibilities.
    samd: STANDARD_PACKAGES - [:serial],

    # ESP8266 mostly working.
    esp8266: STANDARD_PACKAGES - [:serial, :ir_out] + [:ir_out_esp],
    
    # ESP32 mostly working.
    esp32: STANDARD_PACKAGES - [:serial, :ir_out] + [:ir_out_esp],
    
    # RP2040 includes everytyhing except SoftwareSerial and LEDArray.
    rp2040: STANDARD_PACKAGES - [:serial, :led_array],
  }
end
