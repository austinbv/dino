class DinoCLI::Generator
PACKAGES = {
  # These files are always included when building a sketch.
  core: {
    description: "Core Dino Library",
    directive: nil,
    files: [
      "lib/Dino.h",
      "lib/DinoDefines.h",
      "lib/Dino.cpp",
      "lib/DinoCoreIO.cpp",
      "lib/DinoIncludes.cpp",
      "lib/DinoBugWorkaround.cpp",  # See explanation at top of file.
    ]
  },
  servo: {
    description: "Servo support",
    directive: "DINO_LCD",
    files: [
      "lib/DinoServo.cpp",
    ]
  },
  tone: {
    description: "Tone support",
    directive: "DINO_TONE",
    files: [
      "lib/DinoTone.cpp",
    ]
  },
  shift: {
    description: "Shift Register support",
    directive: "DINO_SHIFT",
    files: [
      "lib/DinoShift.cpp",
    ]
  },
  spi: {
    description: "SPI support",
    directive: "DINO_SPI",
    files: [
      "lib/DinoSPI.cpp",
    ]
  },
  lcd: {
    description: "LCD based on Arduino LiquidCrystal",
    directive: "DINO_LCD",
    files: [
      "lib/DinoLCD.cpp",
      "lib/DinoLCD.h",
    ]
  },
  dht: {
    description: "Read DHT temp/humidity sensors",
    directive: "DINO_DHT",
    files: [
      "lib/DinoDHT.cpp",
      "vendor/DHT/DHT.cpp",
      "vendor/DHT/DHT.h",
    ]
  },
  serial: {
    description: "Software serial output",
    directive: "DINO_SERIAL",
    files: [
      "lib/DinoSerial.cpp",
      "lib/DinoSerial.h",
    ]
  },
  ir_out: {
    description: "Transmit infrared signals",
    directive: "DINO_IR_OUT",
    files: [
      "lib/DinoIROut.cpp",
      "vendor/Arduino-IRremote/boarddefs.h",
      "vendor/Arduino-IRremote/IRremote.cpp",
      "vendor/Arduino-IRremote/IRremote.h",
      "vendor/Arduino-IRremote/IRremoteInt.h",
      "vendor/Arduino-IRremote/irSend.cpp",
    ]
  },
  one_wire: {
    description: "OneWire bus support (Just DS18B20 for now)",
    directive: "DINO_ONE_WIRE",
    files: [
      "lib/DinoOneWire.cpp",
      "vendor/OneWire/OneWire.cpp",
      "vendor/OneWire/OneWire.h",
    ]
  },
  i2c: {
    description: "I2C device support",
    directive: "DINO_I2C",
    files: [
      "lib/DinoI2C.cpp",
      "vendor/I2C-Master-Library/I2C.h",
      "vendor/I2C-Master-Library/I2C.cpp",
    ]
  }
}
end
