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
    directive: "DINO_SERVO",
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
      "vendor/arduino-DHT/DHT.cpp",
      "vendor/arduino-DHT/DHT.h",
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
      "vendor/Arduino-IRremote/IRremote.h",
      "vendor/Arduino-IRremote/IRremoteInt.h",
      "vendor/Arduino-IRremote/irSend.cpp",
    ]
  },
  ir_out_esp8266: {
    description: "Transmit infrared signals with the ESP8266",
    directive: "DINO_IR_OUT",
    files: [
      "lib/DinoIROut.cpp",
      "vendor/IRremoteESP8266/src/IRremoteESP8266.h",
      "vendor/IRremoteESP8266/src/IRsend.h",
      "vendor/IRremoteESP8266/src/IRsend.cpp",
      "vendor/IRremoteESP8266/src/IRtimer.h",
      "vendor/IRremoteESP8266/src/IRtimer.cpp",
    ]
  },
  one_wire: {
    description: "OneWire bus support (Just DS18B20 for now)",
    directive: "DINO_ONE_WIRE",
    files: [
      "lib/DinoOneWire.cpp",
      "vendor/OneWire/OneWire.cpp",
      "vendor/OneWire/OneWire.h",
      "vendor/OneWire/util/OneWire_direct_gpio.h",
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
