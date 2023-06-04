class DinoCLI::Generator
  STANDARD_PACKAGES = PACKAGES.each_key.map do |package|
                        package unless PACKAGES[package][:only]
                      end.compact

  TARGETS = {
    # Core is core.
    core: [:core],

    # Specific features for the old mega168 chips.
    mega168: [:core, :one_wire, :tone, :spi_bb, :i2c, :spi, :servo],

    # Other ATmega chips do everything.
    # Add bit bang serial for 328p / UNO since ith as no extra hardware UART.
    mega: STANDARD_PACKAGES + [:uart_bb],

    # No tone or IR support on SAM3X / Due.
    sam3x: STANDARD_PACKAGES - [:tone, :ir_out],
    
    # SAMD includes all standard packages.
    samd: STANDARD_PACKAGES,

    # ESP8266 + ESP32 use a different IR library.
    esp8266: STANDARD_PACKAGES - [:ir_out] + [:ir_out_esp],
    esp32:   STANDARD_PACKAGES - [:ir_out] + [:ir_out_esp],
    
    # RP2040 can't use WS2812 yet.
    rp2040: STANDARD_PACKAGES - [:led_array],
  }
end
