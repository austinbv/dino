class DinoCLI::Generator

# File locations are defined relative to the src/lib directory. 
PACKAGES = {
  # The core package is always included.
  core: {
    description: "Core Dino Library",
    directive: nil,
    files: [
      "Dino.h",
      "DinoDefines.h",
      "Dino.cpp",
      "DinoCoreIO.cpp",
      "DinoPulseInput.cpp",
      "DinoEEPROM.cpp",
      "DinoIncludes.cpp",
      "../../vendor/board-maps/BoardMap.h",
    ]
  },
  one_wire: {
    description: "OneWire bus support",
    directive: "DINO_ONE_WIRE",
    files: [
      "DinoOneWire.cpp",
    ]
  },
  spi_bb: {
    description: "Bit Bang SPI support",
    directive: "DINO_SPI_BB",
    files: [
      "DinoSPIBB.cpp",
    ]
  },
  spi: {
    description: "SPI support",
    directive: "DINO_SPI",
    files: [
      "DinoSPI.cpp",
    ]
  },
  i2c: {
    description: "I2C device support",
    directive: "DINO_I2C",
    files: [
      "DinoI2C.cpp",
    ]
  },
  serial: {
    description: "Software serial output",
    directive: "DINO_SERIAL",
    files: [
      "DinoSerial.cpp",
      "DinoSerial.h",
    ]
  },
  servo: {
    description: "Servo support",
    directive: "DINO_SERVO",
    files: [
      "DinoServo.cpp",
    ]
  },
  tone: {
    description: "Tone support",
    directive: "DINO_TONE",
    files: [
      "DinoTone.cpp",
    ]
  },
  ir_out: {
    description: "Transmit infrared signals",
    directive: "DINO_IR_OUT",
    exclude: [:esp8266, :esp32],
    files: [
      "DinoIROut.cpp",
    ]
  },
  ir_out_esp: {
    description: "Transmit infrared signals with the ESP8266 and ESP32",
    directive: "DINO_IR_OUT",
    only: [:esp8266, :esp32],
    files: [
      "DinoIROutESP.cpp",
    ]
  },
  led_array: {
    description: "Support for various protocosl that control (RGB) LED arrays.",
    directive: "DINO_LED_ARRAY",
    files: [
      "DinoLEDArray.cpp",
    ]
  }
}
end
