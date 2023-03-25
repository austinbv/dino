## Install Arduino Dependencies for Dino (CLI)

Once `arduino-cli` is installed, you can copy and paste into your shell for easy installation.

**Note:** `arduino-cli config init` attempts to create a CLI config file for new installs. It's safe to ignore any errors generated if you already have one.

**Install Everything:**
````shell
arduino-cli config init
arduino-cli config add board_manager.additional_urls https://arduino.esp8266.com/stable/package_esp8266com_index.json
arduino-cli config add board_manager.additional_urls https://raw.githubusercontent.com/espressif/arduino-esp32/gh-pages/package_esp32_index.json
arduino-cli config add board_manager.additional_urls https://github.com/earlephilhower/arduino-pico/releases/download/global/package_rp2040_index.json
arduino-cli core update-index
arduino-cli core install arduino:megaavr
arduino-cli core install arduino:sam
arduino-cli core install arduino:samd
arduino-cli core install esp8266:esp8266
arduino-cli core install esp32:esp32
arduino-cli core install rp2040:rp2040
arduino-cli lib install Servo
arduino-cli lib install Ethernet
arduino-cli lib install WiFi
arduino-cli lib install IRremote@4.0.0
arduino-cli lib install IRremoteESP8266@2.8.4
arduino-cli lib install ESP32Servo
arduino-cli lib install "Adafruit NeoPixel"
````

**AVR-based Arduinos & Clones Only:**
````shell
arduino-cli core update-index
arduino-cli core install arduino:megaavr
arduino-cli lib install Servo
arduino-cli lib install Ethernet
arduino-cli lib install WiFi
arduino-cli lib install IRremote@4.0.0
arduino-cli lib install "Adafruit NeoPixel"
````

**ARM-based Arduinos & Clones Only:**
````shell
arduino-cli core update-index
arduino-cli core install arduino:sam
arduino-cli core install arduino:samd
arduino-cli lib install Servo
arduino-cli lib install Ethernet
arduino-cli lib install WiFi
arduino-cli lib install IRremote@4.0.0
arduino-cli lib install "Adafruit NeoPixel"
````

**ESP8266 Only:**
````shell
arduino-cli config init
arduino-cli config add board_manager.additional_urls https://arduino.esp8266.com/stable/package_esp8266com_index.json
arduino-cli core update-index
arduino-cli core install esp8266:esp8266
arduino-cli lib install IRremoteESP8266@2.8.4
arduino-cli lib install "Adafruit NeoPixel"
````

**ESP32 Only:**
````shell
arduino-cli config init
arduino-cli config add board_manager.additional_urls https://raw.githubusercontent.com/espressif/arduino-esp32/gh-pages/package_esp32_index.json
arduino-cli core update-index
arduino-cli core install esp32:esp32
arduino-cli lib install ESP32Servo
arduino-cli lib install IRremoteESP8266@2.8.4
arduino-cli lib install "Adafruit NeoPixel"
````

**RP2040 Only:**
````shell
arduino-cli config init
arduino-cli config add board_manager.additional_urls https://github.com/earlephilhower/arduino-pico/releases/download/global/package_rp2040_index.json
arduino-cli core update-index
arduino-cli core install rp2040:rp2040
arduino-cli lib install IRremote@4.0.0
````
